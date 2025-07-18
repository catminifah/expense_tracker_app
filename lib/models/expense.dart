class Expense {
  final int id;
  final String title;
  final double amount;
  final String category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        title: json['title'],
        amount: json['amount'].toDouble(),
        category: json['category'],
      );
}
