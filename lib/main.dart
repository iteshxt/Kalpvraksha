import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/theme_provider.dart';
import 'splash_screen.dart';

// Custom page transition builder that removes animation
class _NoTransitionPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // No animation, just return the child widget
  }
}

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
          theme: themeProvider.isDarkMode
              ? ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: const Color(0xFF2A1F5D),
                  primaryColor: const Color(0xFF8B6EFF),
                  pageTransitionsTheme: PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.iOS: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.windows: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.macOS: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.linux: _NoTransitionPageTransitionsBuilder(),
                    },
                  ),
                )
              : ThemeData.light().copyWith(
                  scaffoldBackgroundColor: const Color(0xFFE86D4C),
                  primaryColor: const Color(0xFFFF8F6E),
                  pageTransitionsTheme: PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.iOS: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.windows: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.macOS: _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.linux: _NoTransitionPageTransitionsBuilder(),
                    },
                  ),
                ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
