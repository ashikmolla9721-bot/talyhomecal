import 'package:flutter/material.dart';
import 'expense_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('মেনু ও ক্যাটাগরি'), backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.red),
              title: const Text('বেচা-কেনা হিসাব', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate or info
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.money_off, color: Colors.red),
              title: const Text('খরচ (Expense)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.red),
              title: const Text('সেটিংস (Settings)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
