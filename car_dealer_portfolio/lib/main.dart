import 'package:car_dealer_portfolio/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:car_dealer_portfolio/services/firebase_service.dart' as custom;
import 'screens/showroom_screen.dart';
import '../theme/app_theme.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final firebaseService = custom.FirebaseService();
  await firebaseService.seedInitialInventory();
  runApp(const EliteAutomotiveApp());
  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Dealer Portfolio',
      theme: AppTheme.luxuryTheme,

      home: const ShowroomScreen(),
    );
  }
}
class EliteAutomotiveApp extends StatelessWidget {
  const EliteAutomotiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elite Automotive',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}


