import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String>? allowedRoles;

  const AuthGuard({super.key, required this.child, this.allowedRoles});

  @override
  Widget build(BuildContext context) {
    final authUser = AuthService().currentUser;

    if (authUser == null) {
      _redirect(context, '/landing');
      return const _GuardLoading();
    }

    return FutureBuilder<AppUser?>(
      future: UserService().getCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _GuardLoading();
        }

        final profile = snapshot.data;
        final role = profile?.role ?? 'warga';

        if (allowedRoles != null && !allowedRoles!.contains(role)) {
          _redirect(
            context,
            role == 'penjemput' ? '/collector-dashboard' : '/dashboard',
          );
          return const _GuardLoading();
        }

        return child;
      },
    );
  }

  void _redirect(BuildContext context, String routeName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(routeName, (route) => false);
    });
  }
}

class _GuardLoading extends StatelessWidget {
  const _GuardLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
