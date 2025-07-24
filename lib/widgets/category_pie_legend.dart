import 'package:flutter/material.dart';

class CategoryPieLegend extends StatelessWidget {
  final Map<String, Color> categoryColors;
  const CategoryPieLegend({super.key, required this.categoryColors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: categoryColors.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(backgroundColor: e.value, radius: 6),
            const SizedBox(width: 4),
            Text(
              e.key,
              style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }
}