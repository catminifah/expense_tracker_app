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
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}