import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const _kGreen = Color(0xFF4CAF50);
const _kGreenLight = Color(0xFF81C784);
const _kWhite = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF222222);
const _kGreyHint = Color(0xFF9E9E9E);
const _kFieldBg = Color(0xFFF5F5F5);

// ---------------------------------------------------------------------------
// EditProfileScreen
// ---------------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers ready for future backend integration
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _whatsappController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully.'),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────────
              const _Header(),

              const SizedBox(height: 28),

              // ── Profile Picture ──────────────────────────────────────────
              const _ProfilePicture(),

              const SizedBox(height: 32),

              // ── Editable Fields ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _EditableField(
                      label: 'Nama Pengguna',
                      hint: 'Masukkan nama pengguna',
                      controller: _usernameController,
                      trailingIcon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 20),
                    _EditableField(
                      label: 'Nama Panjang',
                      hint: 'Masukkan nama lengkap',
                      controller: _fullNameController,
                      trailingIcon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 20),
                    _EditableField(
                      label: 'Nomor WhatsApp',
                      hint: 'Masukkan nomor WhatsApp',
                      controller: _whatsappController,
                      trailingIcon: Icons.edit_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Save Button ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SaveButton(label: 'Simpan', onPressed: _onSave),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Header
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button
          Positioned(
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: _kWhite, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Title
          const Text(
            'Informasi Profil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _kWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ProfilePicture
// ---------------------------------------------------------------------------
class _ProfilePicture extends StatelessWidget {
  const _ProfilePicture();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _kGreen, width: 3),
          color: _kWhite,
          boxShadow: [
            BoxShadow(
              color: _kGreen.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/H.png',
            width: 114,
            height: 114,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 114,
                height: 114,
                color: _kGreenLight,
                child: const Icon(Icons.person, size: 64, color: _kWhite),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EditableField  (reusable)
// ---------------------------------------------------------------------------
class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.trailingIcon,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData trailingIcon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        // Text field
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: _kTextDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: _kGreyHint),
            filled: true,
            fillColor: _kFieldBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: Icon(trailingIcon, color: _kGreen, size: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _SaveButton  (reusable)
// ---------------------------------------------------------------------------
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          foregroundColor: _kWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 4,
          shadowColor: _kGreen.withValues(alpha: 0.4),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      ),
    );
  }
}
