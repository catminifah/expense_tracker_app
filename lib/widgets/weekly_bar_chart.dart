import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<int, double> weeklyTotals;
  const WeeklyBarChart({super.key, required this.weeklyTotals});

  @override
  Widget build(BuildContext context) {
    const weekDays = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: weeklyTotals.entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(toY: e.value, color: Colors.indigo)],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 1 || value > 7) return const SizedBox.shrink();
                  return Text(weekDays[value.toInt() - 1], style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}