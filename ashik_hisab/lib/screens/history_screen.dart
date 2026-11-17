import 'package:flutter/material.dart';
import '../models/models.dart';

class HistoryScreen extends StatelessWidget {
  final List<CalcHistoryItem> history;
  final VoidCallback onClear;

  const HistoryScreen({super.key, required this.history, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('হিস্ট্রি (History)'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('হিস্ট্রি মুছে ফেলুন'),
                  content: const Text('আপনি কি সব হিস্ট্রি ডিলিট করতে চান?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
                    TextButton(onPressed: () { onClear(); Navigator.pop(context); }, child: const Text('হ্যাঁ')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('কোনো হিস্ট্রি নেই', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              itemCount: history.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item.expression, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text("=${item.result}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(item.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
