import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseList({super.key, required this.expenses});

  IconData getIcon(String category) {
    switch (category) {
      case 'อาหาร':
        return Icons.fastfood;
      case 'เดินทาง':
        return Icons.directions_bus;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (_, index) {
        final e = expenses[index];
        return ListTile(
          leading: Icon(getIcon(e.category)),
          title: Text(e.title),
          subtitle: Text(e.category),
          trailing: Text('${e.amount} ฿'),
        );
      },
    );
  }
}
