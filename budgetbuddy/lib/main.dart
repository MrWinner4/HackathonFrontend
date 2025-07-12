import 'package:budgetbuddy/screens/onboarding/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/colorscheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Buddy',
      theme: ThemeData(colorScheme: AppColorScheme.colorScheme),
      home: const WelcomeScreen(),
    );
  }
}
