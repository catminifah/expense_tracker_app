class Expense {
  final int id;
  final String title;
  final double amount;
  final String? category;
  final DateTime? createdAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    this.category,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    createdAt: DateTime.parse(json['created_at']),
  );
}