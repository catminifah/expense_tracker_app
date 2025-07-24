import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseTrendLineChart extends StatelessWidget {
  final Map<int, double> dailyTotals; // key = วันที่, value = ยอดรวม

  const ExpenseTrendLineChart({super.key, required this.dailyTotals});

  @override
  Widget build(BuildContext context) {
    final spots = dailyTotals.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.indigo,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeColor: Colors.indigo,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.indigo.withOpacity(0.08),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  value == 0 ? '' : value.toInt().toString(),
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                ),
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
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white,
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) =>
                LineTooltipItem(
                  '${spot.y.toStringAsFixed(0)} ฿',
                  const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                )
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }
}