import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<int, double> monthlyTotals;

  const MonthlyBarChart({super.key, required this.monthlyTotals});

  @override
  Widget build(BuildContext context) {
    final maxY = (monthlyTotals.isNotEmpty)
        ? monthlyTotals.values.fold<double>(
                0.0,
                (prev, curr) => prev > curr ? prev : curr,
              ) +
              100
        : 100.0;
    double safeMaxY(Map<int, double> monthlyTotals) {
      final validValues = monthlyTotals.values.where(
        (e) => e.isFinite && !e.isNaN,
      );
      if (validValues.isEmpty) return 100; // fallback
      final max = validValues.reduce((a, b) => a > b ? a : b);
      return max + 100;
    }

    return BarChart(
      BarChartData(
        maxY: safeMaxY(monthlyTotals),
        barGroups: monthlyTotals.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(toY: entry.value, color: Colors.blueAccent),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value is! double || !value.isFinite || value.isNaN) return const SizedBox.shrink();
                if (value != value.truncateToDouble()) return const SizedBox.shrink();
                final intValue = value.toInt();
                if (intValue < 1 || intValue > 12) return const SizedBox.shrink();
                const months = [
                  'ม.ค.',
                  'ก.พ.',
                  'มี.ค.',
                  'เม.ย.',
                  'พ.ค.',
                  'มิ.ย.',
                  'ก.ค.',
                  'ส.ค.',
                  'ก.ย.',
                  'ต.ค.',
                  'พ.ย.',
                  'ธ.ค.',
                ];
                return Text(
                  months[intValue - 1],
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
      ),
    );
  }
}
