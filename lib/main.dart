import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:finalproject/features/authentication/presentation/provider/auth_provider.dart';
import 'package:finalproject/features/dashboard/presentation/provider/score_provider.dart';
import 'package:finalproject/features/onboarding/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => ScoreProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tactile Play',
      theme: ThemeData(
        fontFamily: 'Jakarta',
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
}
