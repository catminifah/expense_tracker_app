import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseDetail extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const ExpenseDetail({super.key, required this.expense, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('รายละเอียดรายจ่าย'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ชื่อ: ${expense.title}'),
          Text('จำนวนเงิน: ${expense.amount.toStringAsFixed(2)} ฿'),
          Text('หมวดหมู่: ${expense.category ?? "-"}'),
          Text('วันที่: ${expense.createdAt?.toLocal().toString().split(' ')[0] ?? "-"}'),
        ],
      ),
      actions: [
        TextButton(onPressed: onEdit, child: const Text('แก้ไข')),
        TextButton(onPressed: onDelete, child: const Text('ลบ', style: TextStyle(color: Colors.red))),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ปิด')),
      ],
    );
  }
}