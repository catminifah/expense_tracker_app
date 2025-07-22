import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Expense> expenses = [];
  bool isLoading = true;

  // สำหรับ animation
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    loadExpenses();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadExpenses() async {
    final data = await ApiService.fetchExpenses();
    if (data != null) {
      setState(() {
        expenses = data;
        isLoading = false;
      });
      _animationController.forward(from: 0);
    }
  }

  Map<String, double> getCategoryTotals() {
    Map<String, double> data = {};
    for (var e in expenses) {
      String cat = e.category ?? 'ไม่มีหมวดหมู่';
      data[cat] = (data[cat] ?? 0) + e.amount;
    }
    return data;
  }

  Map<int, double> getWeeklyTotals() {
    Map<int, double> weeklyData = {};
    final now = DateTime.now();

    for (var e in expenses) {
      if (e.createdAt == null) continue;

      if (e.createdAt!.year == now.year && e.createdAt!.month == now.month) {
        int weekOfMonth = ((e.createdAt!.day - 1) ~/ 7) + 1;
        weeklyData[weekOfMonth] = (weeklyData[weekOfMonth] ?? 0) + e.amount;
      }
    }

    for (int i = 1; i <= 5; i++) {
      weeklyData[i] = weeklyData[i] ?? 0;
    }

    return weeklyData;
  }

  final List<Color> chartColors = [
    Colors.indigo,
    Colors.orange,
    Colors.pinkAccent,
    Colors.teal,
    Colors.deepPurple,
    Colors.amber,
    Colors.cyan,
    Colors.redAccent,
    Colors.green,
  ];

  Widget buildPieChart() {
    final dataMap = getCategoryTotals();
    if (dataMap.isEmpty) {
      return const Center(child: Text('ยังไม่มีข้อมูลสำหรับกราฟวงกลม'));
    }

    final sections = <PieChartSectionData>[];
    int i = 0;

    dataMap.forEach((category, amount) {
      final color = chartColors[i % chartColors.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${amount.toStringAsFixed(0)} ฿',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _Badge(category, color),
          badgePositionPercentageOffset: 1.2,
        ),
      );
      i++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 4,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (response == null || response.touchedSection == null) return;
            final index = response.touchedSection!.touchedSectionIndex;
            if (index < 0) return;
            final cat = dataMap.keys.elementAt(index);
            final amt = dataMap.values.elementAt(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$cat: ${amt.toStringAsFixed(2)} ฿'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        startDegreeOffset: -90,
      ),
      swapAnimationDuration: const Duration(
        milliseconds: 800,
      ),
      swapAnimationCurve: Curves.easeOut,
    );

  }

  Widget buildBarChart() {
    final weeklyData = getWeeklyTotals();

    double maxY = weeklyData.values.isEmpty
        ? 100
        : (weeklyData.values.reduce((a, b) => a > b ? a : b) * 1.3).clamp(100, double.infinity);

    final barGroups = weeklyData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: chartColors[(entry.key - 1) % chartColors.length],
            width: 24,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: Colors.grey[300],
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('สัปดาห์${value.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.indigo.shade300,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(2)} ฿',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        gridData: FlGridData(show: true),
      ),
      swapAnimationDuration: const Duration(milliseconds: 700),
      swapAnimationCurve: Curves.easeOut,
    );
  }

  void _showAddExpenseDialog() {
    String title = '';
    String category = '';
    String amount = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เพิ่มรายจ่าย"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
              onChanged: (val) => title = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'หมวดหมู่'),
              onChanged: (val) => category = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
              keyboardType: TextInputType.number,
              onChanged: (val) => amount = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("เพิ่ม"),
            onPressed: () async {
              if (title.isNotEmpty && amount.isNotEmpty) {
                final success = await ApiService.addExpense(title, double.parse(amount), category);
                if (success) {
                  Navigator.pop(context);
                  loadExpenses();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('เพิ่มข้อมูลล้มเหลว')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense e) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          e.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          e.category ?? 'ไม่มีหมวดหมู่',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '-${e.amount.toStringAsFixed(2)} ฿',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onLongPress: () => _deleteExpense(e.id),
      ),
    );
  }

  void _deleteExpense(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบรายการรายจ่าย'),
        content: const Text('คุณแน่ใจว่าจะลบรายการนี้หรือไม่?'),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('ลบ'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteExpense(id);
      if (success) {
        loadExpenses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบรายการเรียบร้อยแล้ว')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบรายการล้มเหลว')),
        );
      }
    }
  }

  double getTotalAmount() {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadExpenses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // รวมรายจ่ายเดือนนี้
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "รวมรายจ่ายเดือนนี้",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${getTotalAmount().toStringAsFixed(2)} ฿",
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // กราฟวงกลม
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'ยอดจ่ายตามหมวดหมู่',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(height: 220, child: buildPieChart()),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // กราฟแท่ง
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'ยอดจ่ายรายสัปดาห์ในเดือนนี้',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(height: 220, child: buildBarChart()),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // รายการรายจ่าย
                    expenses.isEmpty
                        ? const Center(child: Text("ยังไม่มีข้อมูลรายจ่าย"))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: expenses.length,
                            itemBuilder: (_, i) => _buildExpenseCard(expenses[i]),
                          ),
                    const SizedBox(height: 80), // ระยะห่างสำหรับ FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.indigo,
        tooltip: 'เพิ่มรายจ่าย',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget แสดง badge ชื่อหมวดหมู่บน Pie Chart
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3, offset: const Offset(1, 1)),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
