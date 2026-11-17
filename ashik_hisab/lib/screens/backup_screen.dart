import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calc = prefs.getString('calc_history') ?? '[]';
      final khata = prefs.getString('tally_customers_list') ?? '[]';
      final notes = prefs.getString('notes_list') ?? '[]';
      final expenses = prefs.getString('expense_list') ?? '[]';

      final Map<String, dynamic> backupMap = {
        'calc_history': jsonDecode(calc),
        'tally_customers_list': jsonDecode(khata),
        'notes_list': jsonDecode(notes),
        'expense_list': jsonDecode(expenses),
        'timestamp': DateTime.now().toIso8601String(),
      };

      String backupData = jsonEncode(backupMap);
      Share.share(backupData, subject: 'Ashik Hisab Backup JSON');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ব্যাকআপ করতে সমস্যা হয়েছে: $e')));
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> decoded = jsonDecode(content);

        final prefs = await SharedPreferences.getInstance();
        if (decoded.containsKey('calc_history')) {
          await prefs.setString('calc_history', jsonEncode(decoded['calc_history']));
        }
        if (decoded.containsKey('tally_customers_list')) {
          await prefs.setString('tally_customers_list', jsonEncode(decoded['tally_customers_list']));
        }
        if (decoded.containsKey('notes_list')) {
          await prefs.setString('notes_list', jsonEncode(decoded['notes_list']));
        }
        if (decoded.containsKey('expense_list')) {
          await prefs.setString('expense_list', jsonEncode(decoded['expense_list']));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সফলভাবে ডাটা রিস্টোর করা হয়েছে! অ্যাপ রিস্টার্ট করুন।'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ফাইল রিস্টোর ব্যর্থ হয়েছে: সঠিক ব্যাকআপ ফাইল নির্বাচন করুন।'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ডাটা ব্যাকআপ ও রিকভারি'), backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ডাটা এক্সপোর্ট ও রিস্টোর', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('আপনার সমস্ত ক্যালকুলেটর হিস্ট্রি, বাকির খাতা এবং নোটপ্যাডের ডাটা ব্যাকআপ করে রাখতে পারেন এবং প্রয়োজনে ফাইল আপলোড করে পুনরায় রিকভার করতে পারেন।'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: () => _exportData(context),
              icon: const Icon(Icons.upload),
              label: const Text('ডাটা ব্যাকআপ বা এক্সপোর্ট করুন', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: () => _restoreData(context),
              icon: const Icon(Icons.download),
              label: const Text('ব্যাকআপ ফাইল থেকে রিস্টোর করুন', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
