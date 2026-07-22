import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrUserScreen extends StatelessWidget {
  const QrUserScreen({super.key});

  // Contoh data user yang akan dimasukkan ke QR
  final String userId = "GRN-2026-0892";
  final String userName = "Andi Wijaya";

  @override
  Widget build(BuildContext context) {
    // Data digabung dalam format JSON string agar rapi saat di-scan petugas
    final String qrData = '{"id_user": "$userId", "nama_user": "$userName"}';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF388E3C), // Hijau agak tua di atas
              Color(0xFF2E7D32), // Hijau lebih pekat di bawah
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header (Tombol Back dan Judul)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Kode QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Kotak Putih & QR Code
              Container(
                padding: const EdgeInsets.all(24.0),
                margin: const EdgeInsets.symmetric(horizontal: 50.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // Sudut agak melengkung
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    gapless: false,
                    // Menambahkan logo Greenie di tengah QR
                    embeddedImage: const AssetImage('assets/Logo.png'), 
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40),
                    ),
                  ),
                ),
              ),

              // 3. Tombol Cetak Kode QR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Warna tombol hijau terang
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Melengkung lonjong sesuai UI kamu
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                    label: const Text(
                      'Cetak Kode QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Fungsi untuk download/save gambar ke galeri
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}