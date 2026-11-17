import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  runApp(const AshikHisabApp());
}

class AshikHisabApp extends StatelessWidget {
  const AshikHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'আশিক হিসাব',
          debugShowCheckedModeBanner: false,
          themeMode: currentTheme,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.red,
            scaffoldBackgroundColor: const Color(0xFFF5F6F8),
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.red,
            scaffoldBackgroundColor: const Color(0xFF121212),
            fontFamily: 'Roboto',
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
