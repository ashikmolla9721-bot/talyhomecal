import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/models.dart';

class CustomerLedgerScreen extends StatefulWidget {
  final Customer customer;

  const CustomerLedgerScreen({super.key, required this.customer});

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();

  Future<void> _saveTransaction(String type) async {
    if (_amountController.text.trim().isEmpty) return;
    double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    String dateStr = DateFormat('d MMM yyyy, hh:mm a', 'en_US').format(DateTime.now());

    setState(() {
      widget.customer.transactions.insert(
        0,
        TransactionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type, // 'gave' (দিলাম/বেচা) or 'got' (পেলাম/জমা)
          amount: amount,
          remark: _remarkController.text.trim().isEmpty ? (type == 'gave' ? 'মাল বিক্রি / বাকি দিলাম' : 'টাকা পেলাম / জমা') : _remarkController.text.trim(),
          date: dateStr,
        ),
      );
    });

    _amountController.clear();
    _remarkController.clear();
    await _updateInStorage();
  }

  Future<void> _updateInStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('tally_customers_list');
      if (data != null) {
        List decoded = jsonDecode(data);
        List<Customer> customers = decoded.map((e) => Customer.fromJson(e)).toList();
        
        int index = customers.indexWhere((c) => c.id == widget.customer.id);
        if (index != -1) {
          customers[index] = widget.customer;
          await prefs.setString('tally_customers_list', jsonEncode(customers.map((e) => e.toJson()).toList()));
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    double balance = widget.customer.totalBalance;
    bool isGet = balance >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.customer.phone.isNotEmpty ? widget.customer.phone : 'নম্বর নেই', style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('বর্তমান স্থিতি:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  isGet ? 'পাবো ৳ ${balance.toStringAsFixed(2)}' : 'দেবো ৳ ${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isGet ? Colors.red.shade700 : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'টাকার পরিমাণ (৳)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _remarkController,
                        decoration: InputDecoration(
                          labelText: 'বিবরণ (ঐচ্ছিক)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                        onPressed: () => _saveTransaction('gave'),
                        child: const Text('দিলাম / বেচা', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                        onPressed: () => _saveTransaction('got'),
                        child: const Text('পেলাম / জমা', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.customer.transactions.isEmpty
                ? const Center(child: Text('কোনো লেনদেন করা হয়নি', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: widget.customer.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = widget.customer.transactions[index];
                      bool isGave = tx.type == 'gave';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(tx.remark, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(tx.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          trailing: Text(
                            '${isGave ? "+" : "-"} ৳${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isGave ? Colors.red.shade700 : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
