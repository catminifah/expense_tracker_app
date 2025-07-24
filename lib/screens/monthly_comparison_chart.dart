import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyComparisonChart extends StatefulWidget {
  const MonthlyComparisonChart({Key? key}) : super(key: key);

  @override
  State<MonthlyComparisonChart> createState() => _MonthlyComparisonChartState();
}

class _MonthlyComparisonChartState extends State<MonthlyComparisonChart> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  bool isLoading = false;

  // ตัวอย่างข้อมูลรายจ่ายแต่ละเดือน (dummy)
  final Map<int, double> monthlyTotals = {
    1: 3200,
    2: 2800,
    3: 3500,
    4: 4000,
    5: 3700,
    6: 4200,
    7: 3900,
    8: 4100,
    9: 3600,
    10: 4300,
    11: 3800,
    12: 4100,
  };

  List<int> get years => [2023, 2024, 2025];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('เปรียบเทียบรายจ่ายรายเดือน', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.indigo),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() { isLoading = true; });
              Future.delayed(const Duration(seconds: 1), () {
                setState(() { isLoading = false; });
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('เลือกปี:', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: selectedYear,
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                  onChanged: (val) => setState(() => selectedYear = val!),
                ),
                const SizedBox(width: 24),
                const Text('เดือน:', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (i) => DropdownMenuItem(value: i+1, child: Text('${i+1}'))),
                  onChanged: (val) => setState(() => selectedMonth = val!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 5000,
                            minY: 0,
                            barTouchData: BarTouchData(enabled: true),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey[200],
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 12, color: Colors.indigo)),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final month = value.toInt();
                                    return Text(month.toString(), style: const TextStyle(fontSize: 12, color: Colors.indigo));
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: monthlyTotals.entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value,
                                    color: e.key == selectedMonth ? Colors.indigo : Colors.indigo.shade200,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(8),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 5000,
                                      color: Colors.indigo.withOpacity(0.06),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              'เดือน $selectedMonth ปี $selectedYear : ${monthlyTotals[selectedMonth]?.toStringAsFixed(2) ?? '-'} บาท',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
