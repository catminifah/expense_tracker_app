import 'package:flutter/material.dart';

class CategoryBudgetForm extends StatelessWidget {
  final Map<String, double> categoryBudgets;
  final List<String> categories;
  final Function(String, double) onBudgetChanged;
  final VoidCallback onSave;

  const CategoryBudgetForm({
    super.key,
    required this.categoryBudgets,
    required this.categories,
    required this.onBudgetChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...categories.map((cat) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'งบหมวด $cat',
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) => onBudgetChanged(cat, double.tryParse(val) ?? 0),
          ),
        )),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: onSave, child: const Text('บันทึกงบหมวด')),
      ],
    );
  }
}