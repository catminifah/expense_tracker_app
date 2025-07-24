import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Expense> expenses = [];
  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final result = await ApiService.fetchExpenses();
    if (result != null) setState(() => expenses = result);
  }

  @override
  Widget build(BuildContext context) {
    final monthlyTotals = <int, double>{for (int i = 1; i <= 12; i++) i: 0.0};
    for (var e in expenses) {
      if (e.createdAt != null) {
        monthlyTotals[e.createdAt!.month] = (monthlyTotals[e.createdAt!.month] ?? 0) + e.amount;
      }
    }
    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      if (e.category != null) {
        categoryTotals[e.category!] = (categoryTotals[e.category!] ?? 0) + e.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('วิเคราะห์รายจ่าย')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('กราฟรายเดือน', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                barGroups: monthlyTotals.entries.map((e) {
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
                        if (value < 1 || value > 12) return const SizedBox.shrink();
                        const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
                        return Text(months[value.toInt() - 1], style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('กราฟหมวดหมู่', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: categoryTotals.entries.map((e) {
                  return PieChartSectionData(
                    value: e.value,
                    title: '${e.key}\n${e.value.toStringAsFixed(0)}฿',
                    color: Colors.primaries[categoryTotals.keys.toList().indexOf(e.key) % Colors.primaries.length],
                    titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}