import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Buku"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.pushNamed(context, '/scan'); // Pindah ke halaman scan
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada data buku."));
          }

          final books = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Agar tabel bisa digeser
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Judul")),
                DataColumn(label: Text("Kode QR")),
                DataColumn(label: Text("Status")),
              ],
              rows: books.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['judul'] ?? '')),
                  DataCell(Text(data['codeQr'] ?? '')),
                  DataCell(Text(data['status'] ?? '')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
