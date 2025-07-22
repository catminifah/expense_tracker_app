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
      amount: double.parse(
        json['amount'].toString(),
      ),
      category: json['category'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}