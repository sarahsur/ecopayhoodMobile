import 'package:flutter/material.dart';

import '../services/user_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const _kGreen = Color(0xFF4CAF50);
const _kGreenLight = Color(0xFF81C784);
const _kGreenDark = Color(0xFF2E7D32);
const _kWhite = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF222222);
const _kGreyHint = Color(0xFF9E9E9E);
const _kCardGreen = Color(0xFFE8F5E9);

// ---------------------------------------------------------------------------
// EditAlamatScreen
// ---------------------------------------------------------------------------
class EditAlamatScreen extends StatefulWidget {
  const EditAlamatScreen({super.key});

  @override
  State<EditAlamatScreen> createState() => _EditAlamatScreenState();
}

class _EditAlamatScreenState extends State<EditAlamatScreen> {
  // Controllers ready for future backend integration
  final _fullNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _detailsController = TextEditingController();
  final _userService = UserService();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _streetController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    final user = await _userService.getCurrentUserProfile();
    if (user == null || !mounted) return;

    _fullNameController.text = user.name;
    _streetController.text = user.address;
    _detailsController.text = user.addressDetail;
  }

  Future<void> _onSaveAddress() async {
    setState(() => _isSaving = true);

    try {
      final profile = await _userService.getCurrentUserProfile();

      await _userService.saveCurrentUserAddress(
        name: _fullNameController.text.trim(),
        phone: profile?.phone ?? '',
        address: _streetController.text.trim(),
        addressDetail: _detailsController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat berhasil disimpan.'),
          backgroundColor: _kGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

              const SizedBox(height: 20),

              // ── Auto-fill Address Card ───────────────────────────────────
              const _AutoAddressCard(),

              const SizedBox(height: 20),

              // ── Address Form ─────────────────────────────────────────────
              _AddressForm(
                fullNameController: _fullNameController,
                streetController: _streetController,
                detailsController: _detailsController,
              ),

              const SizedBox(height: 28),

              // ── Save Button ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SaveButton(
                  label: _isSaving ? 'Menyimpan...' : 'Simpan Alamat',
                  onPressed: _isSaving ? null : _onSaveAddress,
                ),
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
        color: _kGreenLight,
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
              icon: const Icon(Icons.arrow_back, color: _kTextDark, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Title
          const Text(
            'Alamat Baru',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _kTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AutoAddressCard
// ---------------------------------------------------------------------------
class _AutoAddressCard extends StatelessWidget {
  const _AutoAddressCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCardGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kGreenLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.my_location, color: _kGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Isi otomatis :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kGreenDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Placeholder area — GPS integration will go here
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AddressForm
// ---------------------------------------------------------------------------
class _AddressForm extends StatelessWidget {
  const _AddressForm({
    required this.fullNameController,
    required this.streetController,
    required this.detailsController,
  });

  final TextEditingController fullNameController;
  final TextEditingController streetController;
  final TextEditingController detailsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kGreenDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kGreenDark.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _AddressField(
              label: 'Nama lengkap',
              hint: 'Masukkan nama lengkap',
              leadingIcon: Icons.person_outline,
              controller: fullNameController,
            ),
            const SizedBox(height: 18),
            _AddressField(
              label: 'Nama Jalan, Gedung, Nomor Rumah',
              hint: 'Masukkan nama jalan, gedung, nomor rumah',
              leadingIcon: Icons.location_on_outlined,
              controller: streetController,
            ),
            const SizedBox(height: 18),
            _AddressField(
              label: 'Rincian Lainnya (cth, Nomor Blok/Unit)',
              hint: 'Masukkan rincian lainnya bila ada',
              leadingIcon: Icons.location_on_outlined,
              controller: detailsController,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AddressField  (reusable)
// ---------------------------------------------------------------------------
class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.hint,
    required this.leadingIcon,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData leadingIcon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kWhite,
          ),
        ),
        const SizedBox(height: 8),
        // Text field
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: _kTextDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: _kGreyHint),
            filled: true,
            fillColor: _kWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            prefixIcon: Icon(leadingIcon, color: _kGreen, size: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kGreenLight, width: 1.5),
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
  final VoidCallback? onPressed;

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
