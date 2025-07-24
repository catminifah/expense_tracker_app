import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../widgets/expense_category_filter.dart';
import '../widgets/expense_trend_line_chart.dart';
import '../widgets/category_pie_legend.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Expense> expenses = [];
  String? selectedCategory;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final result = await ApiService.fetchExpenses();
    if (result != null) setState(() => expenses = result);
  }

  Map<int, double> get monthlyTotals {
    final Map<int, double> monthly = {for (int i = 1; i <= 12; i++) i: 0.0};
    for (var e in expenses) {
      if (e.createdAt != null && e.createdAt!.year == selectedYear) {
        if (selectedCategory == null || e.category == selectedCategory) {
          monthly[e.createdAt!.month] = (monthly[e.createdAt!.month] ?? 0) + e.amount;
        }
      }
    }
    return monthly;
  }

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (var e in expenses) {
      if (e.category != null && e.createdAt?.year == selectedYear) {
        map[e.category!] = (map[e.category!] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Map<int, double> get dailyTotals {
    final Map<int, double> daily = {};
    for (var e in expenses) {
      if (e.createdAt != null && e.createdAt!.year == selectedYear) {
        final day = e.createdAt!.day;
        daily[day] = (daily[day] ?? 0) + e.amount;
      }
    }
    return daily;
  }

  @override
  Widget build(BuildContext context) {
    final categories = expenses.map((e) => e.category ?? '').toSet().toList()..remove('');
    final categoryColors = {
      for (var i = 0; i < categories.length; i++)
        categories[i]: Colors.primaries[i % Colors.primaries.length]
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('วิเคราะห์รายจ่าย', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.indigo),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'งบประมาณ',
            onPressed: () {
              Navigator.pushNamed(context, '/budget');
            },
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'หน้าหลัก',
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter หมวดหมู่
          ExpenseCategoryFilter(
            categories: categories,
            selectedCategory: selectedCategory,
            onChanged: (cat) => setState(() => selectedCategory = cat),
          ),
          const SizedBox(height: 16),

          // กราฟเปรียบเทียบหลายเดือน (BarChart)
          const Text('กราฟเปรียบเทียบรายเดือน', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 16),
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
                        const monthNames = [
                          'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
                          'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
                        ];
                        if (value < 1 || value > 12) return const SizedBox.shrink();
                        return Text(monthNames[value.toInt() - 1], style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value == 0 ? '' : value.toInt().toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.indigo.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.indigo.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.indigo, width: 1),
                    bottom: BorderSide(color: Colors.indigo, width: 1),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(0)} ฿',
                        const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // กราฟเปรียบเทียบหมวด (PieChart)
          const Text('กราฟเปรียบเทียบหมวดหมู่', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: categoryTotals.entries.map((e) {
                  return PieChartSectionData(
                    value: e.value,
                    title: '${e.key}\n${e.value.toStringAsFixed(0)}฿',
                    color: categoryColors[e.key],
                    titleStyle: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black38, blurRadius: 3)]),
                    radius: 80,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (event, response) {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CategoryPieLegend(categoryColors: categoryColors),
          const SizedBox(height: 24),

          // กราฟเส้นแนวโน้มรายวัน
          const Text('แนวโน้มรายจ่ายรายวัน', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 16),
          ExpenseTrendLineChart(dailyTotals: dailyTotals),
        ],
      ),
    );
  }
}