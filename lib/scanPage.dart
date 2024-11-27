import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
  );
  bool _isProcessing = false; // Flag untuk menghindari duplikasi proses

  @override
  void dispose() {
    _controller.dispose(); // Lepaskan kamera saat halaman ditutup
    super.dispose();
  }

  Future<void> _handleScan(BuildContext context, String code) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Cari buku di Firestore berdasarkan QR code
      final querySnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('codeQr', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // QR code tidak cocok dengan data di Firestore
        _showAlertDialog(context, "Tidak Ditemukan", "QR code tidak cocok dengan data buku di Firestore.");
        return;
      }

      // Ambil data buku yang ditemukan
      final bookDoc = querySnapshot.docs.first;
      final bookData = bookDoc.data();
      final currentStatus = bookData['status'];

      // Tentukan status baru
      String newStatus = (currentStatus == 'ready') ? 'dipinjam' : 'ready';

      // Perbarui status buku di Firestore
      await FirebaseFirestore.instance.collection('books').doc(bookDoc.id).update({
        'status': newStatus,
      });

      // Tampilkan dialog konfirmasi
      _showAlertDialog(context, "Status Buku Diubah",
          "Buku '${bookData['judul']}' telah diperbarui menjadi '$newStatus'.");
    } catch (e) {
      _showAlertDialog(context, "Kesalahan", "Terjadi kesalahan saat memproses QR code: $e");
    } finally {
      setState(() {
        _isProcessing = false; // Reset flag setelah selesai
      });
    }
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
                if (title == "Status Buku Diubah" || title == "Tidak Ditemukan") {
                  Navigator.pop(context); // Kembali ke halaman utama setelah dialog
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pindai QR Code"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(), // Aktifkan/matikan flash
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) async {
          if (_isProcessing) return; // Hindari memproses lebih dari sekali

          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;

            if (code != null && code.isNotEmpty) {
              await _handleScan(context, code);
            } else {
              _showAlertDialog(context, "QR Code Tidak Valid", "QR code tidak mengandung data.");
            }
          }
        },
      ),
    );
  }
}
