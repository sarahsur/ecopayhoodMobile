import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

class RoleRedirectPage extends StatefulWidget {
  const RoleRedirectPage({super.key});

  @override
  State<RoleRedirectPage> createState() => _RoleRedirectPageState();
}

class _RoleRedirectPageState extends State<RoleRedirectPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final authUser = AuthService().currentUser;
    if (authUser == null) {
      _goTo('/landing');
      return;
    }

    final profile = await UserService().getCurrentUserProfile();
    final routeName = profile?.role == 'penjemput'
        ? '/collector-dashboard'
        : '/dashboard';

    _goTo(routeName);
  }

  void _goTo(String routeName) {
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
