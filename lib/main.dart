import 'package:flutter/material.dart';

// Screens
import 'splash_screen.dart';
import 'landing_screen.dart';
import 'login_screen.dart';
import 'signUp.dart';
import 'verifOTP.dart';
import 'dashboard_page.dart';
import 'profile_screen.dart';
import 'notification_page.dart';
import 'qr_generator.dart';
import 'add_address_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const EcoPayhoodApp());
}

class EcoPayhoodApp extends StatelessWidget {
  const EcoPayhoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoPayhood',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),

      // Halaman pertama
      initialRoute: '/',

      routes: {
        // Splash
        '/': (context) => const SplashScreen(),

        // Landing
        '/landing': (context) => const LandingScreen(),

        // Login
        '/login': (context) => const LoginScreen(),

        // Register
        '/signup': (context) => const SignUp(),

        // OTP
        '/otp': (context) => const VerifOTPWidget(),

        // Dashboard
        '/dashboard': (context) => const HomePage(),

        // Profile
        '/profile': (context) => const ProfileScreen(),

        // Notification
        '/notification': (context) => const NotificationPage(),

        // QR
        '/qr': (context) => QrUserScreen(),

        // Add Address
        '/add-address': (context) => const AddAddressPage(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404\nHalaman tidak ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}