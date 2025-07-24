import 'package:flutter/material.dart';

Future<DateTime?> showMonthPickerDialog(BuildContext context, DateTime initialDate) {
  int selectedMonth = initialDate.month;
  int selectedYear = initialDate.year;
  final years = List.generate(5, (i) => DateTime.now().year - i);

  return showDialog<DateTime>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('เลือกเดือน/ปี'),
      content: Row(
        children: [
          DropdownButton<int>(
            value: selectedYear,
            items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
            onChanged: (val) => selectedYear = val!,
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: selectedMonth,
            items: List.generate(12, (i) => DropdownMenuItem(
              value: i + 1,
              child: Text('${i + 1}'),
            )),
            onChanged: (val) => selectedMonth = val!,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, DateTime(selectedYear, selectedMonth)),
          child: const Text('ตกลง'),
        ),
      ],
    ),
  );
}