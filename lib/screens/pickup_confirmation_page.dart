import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_textstyle.dart';

class PickupConfirmationPage extends StatelessWidget {
  final String category;
  final String amount;
  final String unit;
  final Future<void> Function() onConfirm;

  const PickupConfirmationPage({
    super.key,
    required this.category,
    this.amount = '2',
    this.unit = 'kg',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              Color(0xFF2E7D32),
              Color(0xFF1B5E20),
              Color(0xFF0D3D12),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 120.0),
          child: Column(
            children: [
              // Hero image with wavy white circle
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeroImage(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildDescription(),
                ],
              ),

              const SizedBox(height: 24),

              // OKE Button
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 80.0, top: 0.0),
                child: SizedBox(
                  width: 280,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await onConfirm();
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                        return;
                      }

                      // Kembali ke Dashboard (HomePage) yang sudah ada di
                      // navigation stack — bukan ke LandingScreen, dan tidak
                      // membuat instance HomePage baru.
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/dashboard'),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      'OKE',
                      style: AppTextStyle.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: BlobPainter(),
        child: Center(
          child: Image.asset(
            'lib/Assets/images/hero.png',
            width: 140,
            height: 140,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => const Icon(
              Icons.recycling,
              size: 80,
              color: AppColors.darkGreen,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Text(
        'Tunggu Greenie\njemput sampahmu ya...',
        textAlign: TextAlign.center,
        style: AppTextStyle.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Text(
        'Greenie akan sampai di tempatmu dalam\n15 menit.\n\nPastikan kamu telah menata sampah\nyang akan dijemput.',
        textAlign: TextAlign.center,
        style: AppTextStyle.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.9),
          height: 1.5,
        ),
      ),
    );
  }
}

class BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    // Sesuaikan baseRadius agar kelopak bunga (petal) tidak keluar dari batas
    final baseRadius = (size.width / 2) - 20.0;

    final path = Path();
    
    // Create sunflower shape with fewer, larger petals
    final int numPetals = 8;
    final double petalAmplitude = 25.0;

    for (double angle = 0; angle <= 2 * math.pi + 0.05; angle += 0.05) {
      // Use a different wave pattern for sunflower petals
      final waveOffset = petalAmplitude * math.pow(math.sin(numPetals * angle / 2), 2);
      
      final r = baseRadius + waveOffset;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
