// ignore: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'verifOTP.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passconfir = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passconfir.dispose();
    super.dispose();
  }

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

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Wajib diisi' : null,
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
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirmation = _passconfir.text.trim();

    if (password != passwordConfirmation) {
      _showSnackBar('Konfirmasi kata sandi tidak sama');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      final user = credential.user;
      final activeUser = _authService.currentUser;

      if (user != null && activeUser != null) {
        await _userService.saveBasicUser(
          uid: user.id,
          name: name,
          email: user.email ?? email,
        );
      } else if (user != null) {
        if (!mounted) return;
        _showSnackBar(
          'Akun dibuat, tapi session belum aktif. Matikan Confirm email untuk demo kelas.',
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerifOTPWidget()),
      );
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final started = await _authService.signInWithGoogle();
      if (!started) {
        _showSnackBar('Register Google dibatalkan');
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
        _showSnackBar('Ikuti proses register Google di browser');
      }
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mascotHeight = (screenHeight * 0.18).clamp(132.0, 154.0);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _RegisterDecorativeCurvesPainter()),
              ),
              LayoutBuilder(
                builder: (context, viewportConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Spacer(flex: 1),
                              Image.asset(
                                'assets/G.png',
                                height: mascotHeight,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Gabung Sekarang',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mulailah mengubah limbah anda menjadi sesuatu yang bermanfaat bagi bumi dan orang lain.',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDDF5D9),
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
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Buat Akun',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildLabel('Nama Lengkap'),
                                      _buildTextField(
                                        controller: _nameController,
                                        hintText: 'Masukkan nama lengkap',
                                        prefixIcon: Icons.account_circle,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLabel('Email'),
                                      _buildTextField(
                                        controller: _emailController,
                                        hintText: 'Masukkan email',
                                        prefixIcon: Icons.email_outlined,
                                      ),
                                      const SizedBox(height: 8),
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
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLabel('Konfirmasi Kata Sandi'),
                                      _buildTextField(
                                        controller: _passconfir,
                                        hintText: 'Ulangi kata sandi',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscureConfirmPassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: const Color(
                                              0xFF1B5E20,
                                            ).withValues(alpha: 0.7),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF4CAF50,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                            ),
                                          ),
                                          onPressed: _isLoading
                                              ? null
                                              : _submitRegister,
                                          child: Text(
                                            _isLoading
                                                ? 'Memproses...'
                                                : 'Buat Akun',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Atau Daftar dengan',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _isLoading ? null : _registerWithGoogle,
                                child: Container(
                                  width: 56,
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
                                      padding: const EdgeInsets.all(14),
                                      child: Image.asset(
                                        'assets/logogoogle.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sudah punya akun? ',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacementNamed(
                                        AppRoutes.login,
                                      );
                                    },
                                    child: Text(
                                      'Masuk',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B5E20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(flex: 1),
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
      ),
    );
  }
}

class _RegisterDecorativeCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

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
