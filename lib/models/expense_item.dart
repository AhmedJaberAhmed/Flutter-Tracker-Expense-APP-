class ExpenseItem {
  final int? id;
  final String name;
  final String amount;
  final DateTime dateTime;

  ExpenseItem({
    this.id,
    required this.name,
    required this.amount,
    required this.dateTime,
  });

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
    };
  }

   factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
