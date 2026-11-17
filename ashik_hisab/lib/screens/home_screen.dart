import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'khata_screen.dart';
import 'notepad_screen.dart';
import 'backup_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const CalculatorScreen(),
    const KhataScreen(),
    const NotepadScreen(),
    const BackupScreen(),
    const MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'ক্যালকুলেটর'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'বাকির খাতা'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'নোটপ্যাড'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_sync), label: 'ব্যাকআপ'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'মেনু'),
        ],
      ),
    );
  }
}
