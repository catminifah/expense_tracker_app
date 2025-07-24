import 'package:flutter/material.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double total;
  final double budget;
  const BudgetSummaryCard({super.key, required this.total, required this.budget});

  @override
  Widget build(BuildContext context) {
    final over = total > budget;
    return Card(
      color: over ? Colors.red.shade50 : Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ยอดรวมเดือนนี้', style: TextStyle(fontSize: 18)),
            Text(
              '${total.toStringAsFixed(2)} / $budget ฿',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: over ? Colors.red : Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}