import 'package:flutter/material.dart';

class ExpenseCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  const ExpenseCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(cat),
              selected: selectedCategory == cat,
              onSelected: (_) => onChanged(cat),
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.indigo,
              labelStyle: TextStyle(
                color: selectedCategory == cat ? Colors.white : Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ],
      ),
    );
  }
}