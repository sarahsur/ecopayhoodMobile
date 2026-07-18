// ignore: file_names
// ignore: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passconfir.dispose();
    super.dispose();
  }

  // Ikut gaya field() milikmu, tanpa Container kaku + ditambah errorBorder bawaan
  Widget field(
    IconData icon,
    String label,
    String hint,
    TextEditingController c, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87),
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? "Wajib diisi" : null,
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
      if (user != null) {
        await _userService.saveBasicUser(
          uid: user.id,
          name: name,
          email: user.email ?? email,
        );
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/H.png',
                  width: MediaQuery.of(context).size.width,
                  height: 446,
                  fit: BoxFit.fill,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/H.png',
                      width: 205,
                      height: 167,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'Gabung Sekarang',
                      style: GoogleFonts.montserrat(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Mulailah mengubah limbah anda menjadi sesuatu yang bermanfaat bagi bumi dan orang lain.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Card Container utama, sama persis gayanya dengan patokanmu
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff7CC17E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Text(
                                'Buat Akun',
                                style: GoogleFonts.montserrat(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),

                              field(
                                Icons.account_circle,
                                'Nama Lengkap',
                                'Masukkan Nama Lengkap',
                                _nameController,
                              ),
                              field(
                                Icons.email_outlined,
                                'Alamat Email',
                                'Masukkan Alamat Email',
                                _emailController,
                              ),
                              field(
                                Icons.lock,
                                'Kata Sandi',
                                'Masukkan Kata Sandi',
                                _passwordController,
                                obscure: true,
                              ),
                              field(
                                Icons.lock,
                                'Konfirmasi Kata Sandi',
                                'Masukkan Konfirmasi Kata Sandi',
                                _passconfir,
                                obscure: true,
                              ),

                              const SizedBox(height: 8),
                              SizedBox(
                                width: 320,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _submitRegister,
                                  child: Text(
                                    _isLoading ? 'Memproses...' : 'Buat Akun',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
