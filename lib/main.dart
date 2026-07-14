import 'package:flutter/material.dart'; 
import 'homePage.dart';
// import 'verifOTP.dart'; 
// import 'add_address_page.dart'; 
// import 'qr_generator.dart';
void main() { 
  runApp(const MyApp()); 
} 
  
class MyApp extends StatelessWidget { 
  const MyApp({super.key}); 
  
  @override 
  Widget build(BuildContext context) { 
    return MaterialApp( 
      title: 'ecoPayhood', 
      theme: ThemeData( 
        primarySwatch: Colors.blue, 
        useMaterial3: true, 
      ), 
      home: const HomePage(),
      // home: const VerifOTPWidget(), 
      // home: const AddAddressPage(),
      // home: QrUserScreen(),
    ); 
  } 
} 