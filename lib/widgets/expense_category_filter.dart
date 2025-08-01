import 'package:flutter/material.dart';

class ExpenseCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  const ExpenseCategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text("ทั้งหมด"),
          selected: selectedCategory == null,
          onSelected: (_) => onChanged(null),
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.indigo,
          labelStyle: TextStyle(
            color: selectedCategory == null ? Colors.white : Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
        ...categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) => onChanged(cat),
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.indigo,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }
}
