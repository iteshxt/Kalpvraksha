import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muktiya_new/pages/chatbot_page.dart';
import 'package:muktiya_new/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'package:muktiya_new/pages/home_page.dart';
import 'package:muktiya_new/pages/welcome_screen.dart';

// Add ThemeProvider class
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
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
          title: 'Task Dashboard',
          theme: themeProvider.isDarkMode
              ? ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: const Color(0xFF2A1F5D),
                  primaryColor: const Color(0xFF8B6EFF),
                  cardColor: const Color(0xFF382C71),
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: Color(0xFF1A1427),
                  ),
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: Colors.white),
                    bodyMedium: TextStyle(color: Colors.white70),
                  ),
                )
              : ThemeData.light().copyWith(
                  scaffoldBackgroundColor: const Color(0xFFE86D4C), // Orange background
                  primaryColor: const Color(0xFFFF8F6E), // Light orange accent
                  cardColor: const Color(0xFF9E4B33), // Darker orange for cards
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: Color.fromARGB(255, 182, 182, 183),
                  ), // Dark background for bottom bar
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: Colors.white),
                    bodyMedium: TextStyle(color: Colors.white70),
                  ),
                ),
          home: const WelcomeScreen(), // Change this line
        );
      },
    );
  }
}
