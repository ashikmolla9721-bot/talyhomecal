import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
  }

  Future<void> _loadThemeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস (Settings)'), backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('ডার্ক মোড (Dark Mode)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: const Text('অ্যাপের থিম লাইট বা ডার্ক করুন'),
            secondary: const Icon(Icons.dark_mode, color: Colors.red),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info, color: Colors.red),
            title: Text('অ্যাপের সংস্করণ (App Version)'),
            subtitle: Text('1.0.0+1 (আশিক হিসাব)'),
          ),
        ],
      ),
    );
  }
}
