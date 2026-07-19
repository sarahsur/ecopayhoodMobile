import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'signUp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // SnackBar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan kata sandi wajib diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(email: email, password: password);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.roleRedirect);
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final started = await _authService.signInWithGoogle();
      if (!started) {
        _showSnackBar('Login Google dibatalkan');
        return;
      }

      final user = _authService.currentUser;

      if (user != null) {
        await _userService.saveBasicUser(
          uid: user.id,
          name: user.userMetadata?['name']?.toString() ?? 'Warga Ecopayhood',
          email: user.email ?? '',
        );

        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.roleRedirect);
      } else {
        _showSnackBar('Ikuti proses login Google di browser');
      }
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF1B5E20).withValues(alpha: 0.7),
              size: 20,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive scaling: Mascot Height around 150 px
    final double mascotHeight = (screenHeight * 0.18).clamp(140.0, 160.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Bottom Decorative Green Curves
            Positioned.fill(
              child: CustomPaint(painter: DecorativeCurvesPainter()),
            ),

            // Main UI Content
            LayoutBuilder(
              builder: (context, viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),

                            // 1. Top Illustration
                            Center(
                              child: Image.asset(
                                'assets/G.png',
                                height: mascotHeight,
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ), // Spacing: Illustration -> Title
                            // 2. Welcome Text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Selamat Datang Kembali!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize:
                                        30, // Slightly reduced font size (30 px)
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ), // Spacing: Title -> Subtitle
                                Text(
                                  'Senang melihat Anda kembali, silakan masuk untuk melanjutkan aktivitas Anda.',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 20,
                            ), // Spacing: Subtitle -> Login Card
                            // 3. Login Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ), // More compact padding
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFDDF5D9,
                                ), // Light Green Card Background
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Masuk Akun',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ), // Reduced internal spacing
                                  // Username Field
                                  _buildLabel('Email'),
                                  _buildTextField(
                                    controller: _usernameController,
                                    hintText: 'Masukkan email',
                                    prefixIcon: Icons.email_outlined,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // Reduced internal spacing
                                  // Password Field
                                  _buildLabel('Kata Sandi'),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hintText: 'Masukkan kata sandi',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(
                                          0xFF1B5E20,
                                        ).withValues(alpha: 0.7),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ), // Reduced internal spacing
                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showSnackBar('Coming Soon');
                                      },
                                      child: Text(
                                        'Lupa Kata Sandi?',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ), // Reduced internal spacing
                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50, // Approx 50 px height
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF4CAF50,
                                            ).withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _submitLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4CAF50,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _isLoading ? 'Memproses...' : 'Masuk',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(flex: 1),

                            // 4. Divider and Social Login Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Atau Masuk dengan',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: _isLoading
                                          ? null
                                          : _signInWithGoogle,
                                      child: Container(
                                        width: 56, // Approx 56 px diameter
                                        height: 56,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              14.0,
                                            ), // Proportional icon sizing
                                            child: Image.asset(
                                              'assets/logogoogle.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const Spacer(flex: 1),

                            // 5. Bottom Registration Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Belum punya akun? ',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignUp(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Buat Akun',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for drawing the bottom-left and bottom-right curved waves
class DecorativeCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // --- Bottom Left Curves ---
    // Outer wave (Light Green)
    paint.color = const Color(0xFFDDF5D9).withValues(alpha: 0.85);
    final pathLeftOuter = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.82,
        size.width * 0.25,
        size.height * 0.88,
        size.width * 0.35,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathLeftOuter, paint);

    // Inner wave (Primary Green)
    paint.color = const Color(0xFF4CAF50).withValues(alpha: 0.4);
    final pathLeftInner = Path()
      ..moveTo(0, size.height * 0.84)
      ..cubicTo(
        size.width * 0.1,
        size.height * 0.87,
        size.width * 0.18,
        size.height * 0.92,
        size.width * 0.24,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathLeftInner, paint);

    // --- Bottom Right Curves ---
    // Outer wave (Dark Green)
    paint.color = const Color(0xFF1B5E20).withValues(alpha: 0.18);
    final pathRightOuter = Path()
      ..moveTo(size.width, size.height * 0.72)
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.78,
        size.width * 0.72,
        size.height * 0.86,
        size.width * 0.62,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(pathRightOuter, paint);

    // Inner wave (Primary Green)
    paint.color = const Color(0xFF4CAF50).withValues(alpha: 0.3);
    final pathRightInner = Path()
      ..moveTo(size.width, size.height * 0.8)
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.84,
        size.width * 0.82,
        size.height * 0.9,
        size.width * 0.74,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(pathRightInner, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
