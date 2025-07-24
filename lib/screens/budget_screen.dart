import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งงบประมาณ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ใส่งบประมาณ (บาท)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // save budget logic
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกงบประมาณสำเร็จ')));
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}