import 'package:flutter/material.dart';

class ExpenseForm extends StatefulWidget {
  final Function(String, double, String, DateTime) onSubmit;
  final String? initialCategory;
  final DateTime? initialDate;
  const ExpenseForm({super.key, required this.onSubmit, this.initialCategory, this.initialDate});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'ทั่วไป';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'ทั่วไป';
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เพิ่มรายจ่าย'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'ชื่อรายการ')),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'จำนวนเงิน'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['ทั่วไป', 'อาหาร', 'ค่าใช้จ่ายบ้าน', 'เดินทาง', 'บันเทิง', 'อื่นๆ']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Text("เลือกวันที่: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text;
            final amount = double.tryParse(_amountController.text) ?? 0;
            widget.onSubmit(title, amount, _category, _selectedDate);
            Navigator.pop(context);
          },
          child: const Text('บันทึก'),
        )
      ],
    );
  }
}
