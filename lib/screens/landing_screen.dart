import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'signUp.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar styles dynamically for this screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Dark status bar icons (black)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
    );

    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;

    // The curved bottom panel covers about 40% of the screen height.
    final bottomPanelHeight = screenHeight * 0.40;
    // The top content area occupies the remaining 60% of the screen height.
    final topContentHeight = screenHeight * 0.60;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Top
              Color(0xFF3E9C46), // Middle
              Color(0xFF1B5E20), // Bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Central Column (Mascot Group + App Title + Subtitle)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                height: topContentHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mascot Group Container (300 x 300 px)
                          Transform.translate(
                            offset: const Offset(0, 30),
                            child: SizedBox(
                              width: 340,
                              height: 340,
                              child: Stack(
                                children: [
                                  // Main Mascot G (Centered)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/G.png',
                                      width: 180,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  // Floating Mascot M (Top-Left of G)
                                  Positioned(
                                    left: 90,
                                    top: 5,
                                    child: _buildFloatingMascot(
                                      'assets/M.png',
                                    ),
                                  ),

                                  // Floating Mascot K (Above G)
                                  Positioned(
                                    top: 5,
                                    left: 180,
                                    child: _buildFloatingMascot(
                                      'assets/K.png',
                                    ),
                                  ),

                                  // Floating Mascot S (Top-Right of G)
                                  Positioned(
                                    right: 7,
                                    top: 47,
                                    child: _buildFloatingMascot(
                                      'assets/S.png',
                                    ),
                                  ),

                                  // Floating Mascot O (Bottom-Right of G)
                                  Positioned(
                                    right: 0,
                                    top: 145,
                                    child: _buildFloatingMascot(
                                      'assets/O.png',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Text(
                              'EcoPayhood',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 30,
                                fontWeight: FontWeight.w800, // Bold (800)
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 0),

                          // Subtitle
                          Transform.translate(
                            offset: const Offset(0, -35),
                            child: Text(
                              'Hijau Bersama, Untung Bersama',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 17,
                                fontWeight: FontWeight.w600, // SemiBold
                                color: Colors.white.withValues(
                                  alpha: 0.9,
                                ), // 90% opacity
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 6. Curved Bottom Panel
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipPath(
                  clipper: BottomPanelClipper(),
                  child: Container(
                    width: double.infinity,
                    height: bottomPanelHeight,
                    color: const Color(0xFFD6E8D2),
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Adjust top padding to push content below the curved wave peak
                        const SizedBox(height: 75),

                        // Description Text
                        Text(
                          'Masuk atau daftar untuk mulai\nberpartisipasi dalam program daur ulang',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF1B5E20), // Dark Green
                            fontSize: 18,
                            fontWeight: FontWeight.bold, // Bold
                            height: 1.4,
                          ),
                        ),

                        const Spacer(),

                        // Buttons Section (Horizontal row with equal widths and 20px spacing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left Button: Buat Akun
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            const SignUp(),
                                        transitionsBuilder:
                                            (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                            },
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF1B5E20,
                                    ), // Dark Green
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    'Buat Akun',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // Right Button: Masuk
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            const LoginScreen(),
                                        transitionsBuilder:
                                            (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(
                                      0xFF1B5E20,
                                    ), // Dark Green
                                    elevation: 0,
                                    side: const BorderSide(
                                      color: Color(0xFF1B5E20), // Dark Green
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    'Masuk',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Bottom safety spacer
                        const SizedBox(height: 36),
                      ],
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

  // Helper widget to construct 70 px white circular containers for floating mascots
  Widget _buildFloatingMascot(String assetPath) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(
            11.0,
          ), // Padding to scale the mascot nicely
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// Custom Clipper to generate the premium curved bottom panel
class BottomPanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Wave starting on the left side
    path.moveTo(0, 75);

    // Smooth quadratic curve to rise upward and end smoothly on the right side
    path.quadraticBezierTo(size.width * 0.35, 10, size.width, 45);

    // Connect remaining corners of the bottom container
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
