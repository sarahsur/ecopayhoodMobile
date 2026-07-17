import 'package:flutter/material.dart';
import 'landing_screen.dart';
import 'edit_profile.dart';
import 'edit_alamat.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const _kGreen = Color(0xFF4CAF50);
const _kGreenLight = Color(0xFF81C784);
const _kWhite = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF222222);

// ---------------------------------------------------------------------------
// ProfileScreen
// ---------------------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Green Header ──────────────────────────────────────────────
            const _GreenHeader(),

            // ── 24px gap ─────────────────────────────────────────────────
            const SizedBox(height: 24),

            // ── Avatar + Username ─────────────────────────────────────────
            const _ProfileAvatar(),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Bima Sakti',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _kTextDark,
                ),
              ),
            ),

            // ── 30px gap before menu ──────────────────────────────────────
            const SizedBox(height: 30),

            // ── Menu List ─────────────────────────────────────────────────
            ProfileMenuTile(
              icon: Icons.edit,
              label: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            ProfileMenuTile(
              icon: Icons.location_on,
              label: 'Address',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditAlamatScreen(),
                  ),
                );
              },
            ),

            // ── Push logout to bottom ─────────────────────────────────────
            const Spacer(),

            // ── Logout Button ─────────────────────────────────────────────
            const _LogoutButton(),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GreenHeader
// ---------------------------------------------------------------------------
class _GreenHeader extends StatelessWidget {
  const _GreenHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back arrow
          Positioned(
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: _kTextDark),
              onPressed: () {
                final nav = Navigator.of(context);
                if (nav.canPop()) nav.pop();
              },
            ),
          ),

          // Centered title
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 30,
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
// _ProfileAvatar
// ---------------------------------------------------------------------------
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _kGreen, width: 2.5),
          color: _kWhite,
        ),
        child: ClipOval(
          child: Image.asset(
            'lib/Assets/H.png',
            width: 110,
            height: 110,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Graceful fallback if image is missing
              return Container(
                width: 110,
                height: 110,
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
// ProfileMenuTile  (reusable)
// ---------------------------------------------------------------------------
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: _kWhite,
            border: Border(bottom: BorderSide(color: _kGreenLight, width: 1.2)),
          ),
          child: Row(
            children: [
              // Leading icon
              Icon(icon, color: _kGreen, size: 24),
              const SizedBox(width: 16),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _kTextDark,
                  ),
                ),
              ),

              // Trailing chevron
              const Icon(Icons.chevron_right, color: _kGreen, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LogoutButton
// ---------------------------------------------------------------------------
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 55,
        decoration: BoxDecoration(
          color: _kGreen,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _kGreen.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              // Logout: hapus seluruh halaman setelah login dari stack
              // (Dashboard, Profile, dll) dan jadikan LandingScreen sebagai
              // root baru. Predicate `(route) => false` berarti tidak ada
              // route lama yang dipertahankan, jadi tombol back tidak bisa
              // kembali ke Dashboard.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (route) => false,
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: _kWhite, size: 24),
                SizedBox(width: 10),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
