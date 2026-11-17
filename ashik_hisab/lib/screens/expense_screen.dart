import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<ExpenseItem> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('expense_list');
      if (data != null) {
        final List decoded = jsonDecode(data);
        setState(() {
          _expenses = decoded.map((e) => ExpenseItem.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('expense_list', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _addExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('নতুন খরচ যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'খরচের বিবরণ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'টাকার পরিমাণ (৳)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty && amountController.text.trim().isNotEmpty) {
                double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                String dateStr = DateFormat('d MMM yyyy, hh:mm a', 'en_US').format(DateTime.now());
                setState(() {
                  _expenses.insert(0, ExpenseItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    amount: amount,
                    date: dateStr,
                  ));
                  _saveExpenses();
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('সেভ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = _expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('খরচের খাতা'), backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('মোট খরচ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('৳ ${totalExpense.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('কোনো খরচ এন্ট্রি করা হয়নি', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final exp = _expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(exp.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('৳ ${exp.amount.toStringAsFixed(2)}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _expenses.removeAt(index);
                                    _saveExpenses();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpenseDialog,
        label: const Text('খরচ যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}
