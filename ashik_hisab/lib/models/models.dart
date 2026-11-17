class TransactionItem {
  final String id;
  final String type; // 'gave' or 'got'
  final double amount;
  final String remark;
  final String date;

  TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.remark,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'remark': remark,
        'date': date,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
        id: json['id'] ?? '',
        type: json['type'] ?? 'gave',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        remark: json['remark'] ?? '',
        date: json['date'] ?? '',
      );
}

class Customer {
  String id;
  String name;
  String phone;
  String type; // 'customer' or 'supplier'
  List<TransactionItem> transactions;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.transactions,
  });

  double get totalBalance {
    double balance = 0;
    for (var tx in transactions) {
      if (tx.type == 'gave') {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'type': type,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        type: json['type'] ?? 'customer',
        transactions: (json['transactions'] as List?)
                ?.map((t) => TransactionItem.fromJson(t))
                .toList() ??
            [],
      );
}

class ExpenseItem {
  String id;
  String title;
  double amount;
  String date;

  ExpenseItem({required this.id, required this.title, required this.amount, required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'amount': amount, 'date': date};
  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
      );
}

class NoteItem {
  String id;
  String title;
  String content;
  String date;

  NoteItem({required this.id, required this.title, required this.content, required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'content': content, 'date': date};
  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        date: json['date'] ?? '',
      );
}

class CalcHistoryItem {
  final String expression;
  final String result;
  final String date;

  CalcHistoryItem({required this.expression, required this.result, required this.date});

  Map<String, dynamic> toJson() => {'expression': expression, 'result': result, 'date': date};
  factory CalcHistoryItem.fromJson(Map<String, dynamic> json) => CalcHistoryItem(
        expression: json['expression'] ?? '',
        result: json['result'] ?? '',
        date: json['date'] ?? '',
      );
}
