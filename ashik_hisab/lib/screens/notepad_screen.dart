import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/models.dart';

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  List<NoteItem> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('notes_list');
      if (data != null) {
        final List decoded = jsonDecode(data);
        setState(() {
          _notes = decoded.map((e) => NoteItem.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('notes_list', jsonEncode(_notes.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _addOrEditNote({NoteItem? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(note == null ? 'নতুন নোট লিখুন' : 'নোট এডিট করুন', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'নোটের শিরোনাম',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'বিস্তারিত বিবরণ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                String dateStr = DateFormat('d MMMM, yyyy - hh:mm a', 'en_US').format(DateTime.now());
                setState(() {
                  if (note == null) {
                    _notes.insert(0, NoteItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      date: dateStr,
                    ));
                  } else {
                    note.title = titleController.text.trim();
                    note.content = contentController.text.trim();
                    note.date = dateStr;
                  }
                  _saveNotes();
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
    return Scaffold(
      appBar: AppBar(title: const Text('তারিখভিত্তিক নোটপ্যাড'), backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
      body: _notes.isEmpty
          ? const Center(child: Text('কোনো নোট সংরক্ষণ করা নেই', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              itemCount: _notes.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(note.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                            IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () => _addOrEditNote(note: note)),
                            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () {
                              setState(() {
                                _notes.removeAt(index);
                                _saveNotes();
                              });
                            }),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(note.content, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                        const SizedBox(height: 10),
                        Text(note.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditNote(),
        label: const Text('নোট যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.note_add, color: Colors.white),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}
