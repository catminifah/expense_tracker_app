import 'package:flutter/material.dart';

class BudgetForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const BudgetForm({
    super.key,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ตั้งงบประมาณรายเดือน'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'ใส่งบประมาณ (บาท)'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
        ElevatedButton(onPressed: onSave, child: const Text('บันทึก')),
      ],
    );
  }
}
