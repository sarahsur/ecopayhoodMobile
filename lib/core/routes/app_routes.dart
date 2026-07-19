import 'package:flutter/material.dart';

import '../../screens/add_address_page.dart';
import '../../screens/collector_dashboard_page.dart';
import '../../screens/collector_scan_page.dart';
import '../../screens/dashboard_page.dart';
import '../../screens/landing_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/notification_page.dart';
import '../../screens/profile_screen.dart';
import '../../screens/pickup_request_list_page.dart';
import '../../screens/qr_generator.dart';
import '../../screens/rewards_page.dart';
import '../../screens/role_redirect_page.dart';
import '../../screens/signUp.dart';
import '../../screens/splash_screen.dart';
import '../../screens/verifOTP.dart';
import '../../widgets/auth_guard.dart';

class AppRoutes {
  static const splash = '/';
  static const landing = '/landing';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const roleRedirect = '/role-redirect';
  static const dashboard = '/dashboard';
  static const collectorDashboard = '/collector-dashboard';
  static const collectorScan = '/collector-scan';
  static const profile = '/profile';
  static const notification = '/notification';
  static const pickupRequests = '/pickup-requests';
  static const qr = '/qr';
  static const addAddress = '/add-address';
  static const rewards = '/rewards';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      landing: (context) => const LandingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUp(),
      otp: (context) => const VerifOTPWidget(),
      roleRedirect: (context) => const RoleRedirectPage(),
      dashboard: (context) =>
          const AuthGuard(allowedRoles: ['warga'], child: HomePage()),
      collectorDashboard: (context) => const AuthGuard(
        allowedRoles: ['penjemput'],
        child: CollectorDashboardPage(),
      ),
      collectorScan: (context) => const AuthGuard(
        allowedRoles: ['penjemput'],
        child: CollectorScanPage(),
      ),
      profile: (context) => const AuthGuard(child: ProfileScreen()),
      notification: (context) => const AuthGuard(child: NotificationPage()),
      pickupRequests: (context) => const AuthGuard(
        allowedRoles: ['warga'],
        child: PickupRequestListPage(),
      ),
      qr: (context) =>
          const AuthGuard(allowedRoles: ['warga'], child: QrUserScreen()),
      addAddress: (context) =>
          const AuthGuard(allowedRoles: ['warga'], child: AddAddressPage()),
      rewards: (context) =>
          const AuthGuard(allowedRoles: ['warga'], child: RewardsPage()),
    };
  }
}
