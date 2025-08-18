import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/theme_provider.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Kalpvraksha',
          theme:
              themeProvider.isDarkMode
                  ? ThemeData.dark().copyWith(
                    scaffoldBackgroundColor: const Color(0xFF2A1F5D),
                    primaryColor: const Color(0xFF8B6EFF),
                  )
                  : ThemeData.light().copyWith(
                    scaffoldBackgroundColor: const Color(0xFFE86D4C),
                    primaryColor: const Color(0xFFFF8F6E),
                  ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
