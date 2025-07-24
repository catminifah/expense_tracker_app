import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  const ExpenseListTile({super.key, required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Text(expense.title.characters.first, style: const TextStyle(color: Colors.white)),
        ),
        title: Text(expense.title),
        subtitle: Text('${expense.category ?? "ไม่ระบุ"}  ${expense.createdAt?.toLocal().toString().split(' ')[0] ?? ""}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${expense.amount.toStringAsFixed(2)} ฿'),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}