import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/app_user.dart';
import '../services/user_service.dart';

class QrUserScreen extends StatelessWidget {
  final AppUser? appUser;

  const QrUserScreen({super.key, this.appUser});

  @override
  Widget build(BuildContext context) {
    if (appUser != null) {
      return _QrContent(appUser: appUser!);
    }

    return FutureBuilder<AppUser?>(
      future: UserService().getCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Data user belum tersedia. Login dan lengkapi alamat dulu.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return _QrContent(appUser: user);
      },
    );
  }
}

class _QrContent extends StatelessWidget {
  final AppUser appUser;

  const _QrContent({required this.appUser});

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'type': 'ECOPAYHOOD_WARGA',
      'uid': appUser.uid,
      'name': appUser.name,
      'email': appUser.email,
      'phone': appUser.phone,
      'address': appUser.address,
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
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
              Container(
                padding: const EdgeInsets.all(24.0),
                margin: const EdgeInsets.symmetric(horizontal: 50.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    gapless: false,
                    embeddedImage: const AssetImage('assets/Logo.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                appUser.name.isEmpty ? 'Warga Ecopayhood' : appUser.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                appUser.email,
                style: const TextStyle(color: Colors.white70),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                  vertical: 32.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Cetak Kode QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur cetak QR masuk pengembangan berikutnya',
                          ),
                        ),
                      );
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
