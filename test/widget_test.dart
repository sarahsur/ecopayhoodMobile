// Basic smoke test for the EcoPayhood app.
//
// The default template test (counter app with MyApp/'+' icon) was replaced
// because this project's root widget is EcoPayhoodApp and it has no counter
// UI — the app starts on SplashScreen and navigates on tap.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecopayhood/main.dart';

void main() {
  testWidgets('App launches and shows the Splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EcoPayhoodApp());

    // SplashScreen should be the first thing shown.
    expect(find.text('EcoPayhood'), findsOneWidget);
    expect(find.text('Hijau Bersama, Untung Bersama'), findsOneWidget);
  });

  testWidgets('Tapping the Splash screen navigates to Landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoPayhoodApp());

    // Tap anywhere on the splash screen to trigger navigation.
    await tester.tap(find.byType(GestureDetector));

    // Let the fade transition (350ms) finish.
    await tester.pumpAndSettle();

    // LandingScreen shows the "Buat Akun" / "Masuk" buttons.
    expect(find.text('Buat Akun'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
