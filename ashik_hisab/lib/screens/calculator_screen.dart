import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _expression = "";
  List<CalcHistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? histString = prefs.getString('calc_history');
      if (histString != null) {
        final List decoded = jsonDecode(histString);
        setState(() {
          _history = decoded.map((e) => CalcHistoryItem.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('calc_history', jsonEncode(_history.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _output = "0";
        _expression = "";
      } else if (value == "⌫") {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else if (value == "=") {
        try {
          String finalExpression = _output.replaceAll('×', '*').replaceAll('÷', '/');
          double result = _evalExpression(finalExpression);
          String resStr = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
          
          String dateStr = DateFormat('d MMMM, yyyy', 'en_US').format(DateTime.now());
          _history.insert(0, CalcHistoryItem(expression: _output, result: resStr, date: dateStr));
          if (_history.length > 50) _history.removeLast();
          _saveHistory();

          _expression = _output;
          _output = resStr;
        } catch (e) {
          _output = "Error";
        }
      } else {
        if (_output == "0" && value != ".") {
          _output = value;
        } else {
          _output += value;
        }
      }
    });
  }

  double _evalExpression(String expr) {
    try {
      List<String> tokens = [];
      String current = "";
      for (int i = 0; i < expr.length; i++) {
        var char = expr[i];
        if ("+-*/".contains(char)) {
          tokens.add(current);
          tokens.add(char);
          current = "";
        } else {
          current += char;
        }
      }
      tokens.add(current);
      
      List<dynamic> pass1 = [];
      for (int i = 0; i < tokens.length; i++) {
        if (tokens[i] == '*') {
          double prev = double.parse(pass1.removeLast());
          double next = double.parse(tokens[++i]);
          pass1.add((prev * next).toString());
        } else if (tokens[i] == '/') {
          double prev = double.parse(pass1.removeLast());
          double next = double.parse(tokens[++i]);
          pass1.add((prev / next).toString());
        } else {
          pass1.add(tokens[i]);
        }
      }

      double result = double.parse(pass1[0]);
      for (int i = 1; i < pass1.length; i += 2) {
        String op = pass1[i];
        double next = double.parse(pass1[i + 1]);
        if (op == '+') result += next;
        if (op == '-') result -= next;
      }
      return result;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আশিক হিসাব - ক্যালকুলেটর', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.history, color: Colors.red, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryScreen(history: _history, onClear: () {
                setState(() => _history.clear());
                _saveHistory();
              })),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expression, style: const TextStyle(fontSize: 24, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(_output, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                children: [
                  _buildButtonRow(["C", "( )", "%", "÷"], [Colors.grey.shade200, Colors.grey.shade200, Colors.grey.shade200, Colors.red.shade700]),
                  _buildButtonRow(["7", "8", "9", "×"], [Colors.white, Colors.white, Colors.white, Colors.red.shade700]),
                  _buildButtonRow(["4", "5", "6", "-"], [Colors.white, Colors.white, Colors.white, Colors.red.shade700]),
                  _buildButtonRow(["1", "2", "3", "+"], [Colors.white, Colors.white, Colors.white, Colors.red.shade700]),
                  _buildButtonRow([".", "0", "⌫", "="], [Colors.white, Colors.white, Colors.white, Colors.red.shade700]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels, List<Color> bgColors) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(labels.length, (index) {
          bool isOperator = bgColors[index] == Colors.red.shade700;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColors[index],
                  foregroundColor: isOperator ? Colors.white : Colors.black87,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _onButtonPressed(labels[index]),
                child: Text(labels[index], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }),
      ),
    );
  }
}
