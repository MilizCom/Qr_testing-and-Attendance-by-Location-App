import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_perpustakaan/beginPage.dart';
import 'package:qr_perpustakaan/loginPage.dart';
import 'package:qr_perpustakaan/mapsPage.dart';
import 'package:qr_perpustakaan/registrasionPage.dart';
import 'package:qr_perpustakaan/scanPage.dart';
import 'package:qr_perpustakaan/utamaPage.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Rute awal aplikasi
      initialRoute: '/start',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/scan': (context) =>  ScanPage(),
        '/maps': (context) =>  LocationPage(),
        '/start': (context) =>  BeginPage(),
      },
    );
  }
}
