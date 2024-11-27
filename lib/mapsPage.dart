import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _locationMessage = "Lokasi belum diambil";
  String _userName = ""; // Nama default
  double targetLatitude = -5.2116846;
  double targetLongitude = 119.5057914;

  // Fungsi untuk mengambil nama pengguna dari Firestore
  Future<void> _getUserName() async {
    try {
      // Mengambil semua dokumen dari koleksi 'users'
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users') // Koleksi 'users'
          .get(); // Ambil semua dokumen dalam koleksi

      // Jika ada dokumen dalam koleksi 'users', kita ambil nama dari dokumen pertama
      if (usersSnapshot.docs.isNotEmpty) {
        // Ambil data nama pengguna dari dokumen pertama
        DocumentSnapshot userDoc =
            usersSnapshot.docs[0]; // Ambil dokumen pertama
        setState(() {
          _userName =
              userDoc['name'] ?? "Nama tidak ditemukan"; // Ambil field 'name'
        });
      } else {
        setState(() {
          _userName = "Pengguna tidak ditemukan";
        });
      }
    } catch (e) {
      setState(() {
        _userName = "Terjadi kesalahan: $e";
      });
    }
  }

  // Fungsi untuk meminta izin dan mendapatkan lokasi terkini
  Future<void> _getCurrentLocation() async {
    // Memeriksa apakah izin lokasi diberikan
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Mendapatkan lokasi terkini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double tolerance = 0.0001; // Toleransi dalam derajat
      if ((position.latitude - targetLatitude).abs() <= tolerance &&
          (position.longitude - targetLongitude).abs() <= tolerance) {
        setState(() {
          _locationMessage = "Absen Telah Tercatat";
        });
      } else {
        setState(() {
          _locationMessage =
              "Anda tidak berada di lokasi yang dituju, coba pindah ke lokasi yang benar.";
        });
      }
    } else {
      setState(() {
        _locationMessage = "Izin lokasi tidak diberikan.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserName(); // Ambil nama pengguna saat halaman pertama kali dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lokasi Terkini"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Menampilkan nama pengguna yang diambil dari Firestore
              Text("Selamat Datang $_userName",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text("Absen Sekarang"),
              ),
              SizedBox(height: 20),
              Text(
                _locationMessage,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
