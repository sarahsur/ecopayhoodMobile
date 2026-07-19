import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_routes.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'SUPABASE_URL dan SUPABASE_ANON_KEY belum diisi lewat --dart-define',
      );
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );

    runApp(const EcoPayhoodApp());
  } catch (error) {
    runApp(BackendSetupErrorApp(error: error));
  }
}

class EcoPayhoodApp extends StatelessWidget {
  const EcoPayhoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoPayhood',

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),

      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404\nHalaman tidak ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BackendSetupErrorApp extends StatelessWidget {
  final Object error;

  const BackendSetupErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Supabase belum siap',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Jalankan aplikasi dengan SUPABASE_URL dan '
                  'SUPABASE_ANON_KEY dari project Supabase.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
