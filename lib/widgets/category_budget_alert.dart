import 'package:flutter/material.dart';

void showCategoryBudgetAlert(BuildContext context, String category) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('แจ้งเตือน'),
      content: Text('หมวด "$category" ใช้จ่ายเกินงบที่กำหนดแล้ว!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ตกลง'),
        ),
      ],
    ),
  );
}