import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import 'customer_ledger_screen.dart';

class KhataScreen extends StatefulWidget {
  const KhataScreen({super.key});

  @override
  State<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends State<KhataScreen> {
  List<Customer> _customers = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('tally_customers_list');
      if (data != null) {
        final List decoded = jsonDecode(data);
        setState(() {
          _customers = decoded.map((e) => Customer.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('tally_customers_list', jsonEncode(_customers.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _addCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String type = 'customer'; // customer or supplier

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('নতুন কাস্টমার/সাপ্লায়ার', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('কাস্টমার'),
                      selected: type == 'customer',
                      selectedColor: Colors.red.shade100,
                      onSelected: (val) => setDialogState(() => type = 'customer'),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('সাপ্লায়ার'),
                      selected: type == 'supplier',
                      selectedColor: Colors.red.shade100,
                      onSelected: (val) => setDialogState(() => type = 'supplier'),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'নাম',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'মোবাইল নম্বর',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    _customers.insert(
                      0,
                      Customer(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        type: type,
                        transactions: [],
                      ),
                    );
                    _saveCustomers();
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('নিশ্চিত'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalGet = 0; // মোট পাবো
    double totalGive = 0; // মোট দেবো

    for (var c in _customers) {
      double bal = c.totalBalance;
      if (bal > 0) {
        totalGet += bal;
      } else if (bal < 0) {
        totalGive += bal.abs();
      }
    }

    List<Customer> filteredList = _customers.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('বাকির খাতা - টালিখাতা'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Dashboard Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('মোট পাবো', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text('৳ ${totalGet.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                    ],
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('মোট দেবো', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text('৳ ${totalGive.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'নাম বা নম্বর দিয়ে খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Customer List
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text('কোনো কাস্টমার বা সাপ্লায়ার নেই', style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final cust = filteredList[index];
                      double bal = cust.totalBalance;
                      bool isGet = bal >= 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerLedgerScreen(customer: cust),
                              ),
                            );
                            _loadCustomers();
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Text(cust.name.isNotEmpty ? cust.name[0].toUpperCase() : 'C',
                                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(cust.phone.isNotEmpty ? cust.phone : 'নম্বর নেই', style: const TextStyle(fontSize: 13)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isGet ? 'পাবো: ৳${bal.toStringAsFixed(2)}' : 'দেবো: ৳${bal.abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isGet ? Colors.red.shade700 : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
        onPressed: _addCustomerDialog,
        label: const Text('কাস্টমার যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.person_add, color: Colors.white),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}
