import 'package:flutter/material.dart';

import '../../screens/add_address_page.dart';
import '../../screens/dashboard_page.dart';
import '../../screens/landing_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/notification_page.dart';
import '../../screens/profile_screen.dart';
import '../../screens/pickup_request_list_page.dart';
import '../../screens/qr_generator.dart';
import '../../screens/signUp.dart';
import '../../screens/splash_screen.dart';
import '../../screens/verifOTP.dart';

class AppRoutes {
  static const splash = '/';
  static const landing = '/landing';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const notification = '/notification';
  static const pickupRequests = '/pickup-requests';
  static const qr = '/qr';
  static const addAddress = '/add-address';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      landing: (context) => const LandingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUp(),
      otp: (context) => const VerifOTPWidget(),
      dashboard: (context) => const HomePage(),
      profile: (context) => const ProfileScreen(),
      notification: (context) => const NotificationPage(),
      pickupRequests: (context) => const PickupRequestListPage(),
      qr: (context) => const QrUserScreen(),
      addAddress: (context) => const AddAddressPage(),
    };
  }
}
