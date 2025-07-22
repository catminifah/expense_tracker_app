import 'package:collection/collection.dart';
import 'package:expense_tracker_app/models/expense.dart';
import 'package:expense_tracker_app/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Expense>?> futureExpenses;

  @override
  void initState() {
    super.initState();
    futureExpenses = ApiService.fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker'), centerTitle: true),
      body: FutureBuilder<List<Expense>?>(
        future: futureExpenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No expenses found."));
          } else {
            final expenses = snapshot.data!;
            final categoryTotals = _calculateCategoryTotals(expenses);
            return Column(
              children: [
                const SizedBox(height: 16),
                _buildPieChart(categoryTotals),
                const SizedBox(height: 24),
                Expanded(child: _buildCategorySummary(categoryTotals)),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add expense
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> data = {};
    for (var expense in expenses) {
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

  Widget _buildPieChart(Map<String, double> dataMap) {
    final total = dataMap.values.fold(0.0, (a, b) => a + b);
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: dataMap.entries.mapIndexed((index, entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            return PieChartSectionData(
              value: entry.value,
              color: colors[index % colors.length],
              title: "$percentage%",
              radius: 70,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategorySummary(Map<String, double> dataMap) {
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];

    return ListView.builder(
      itemCount: dataMap.length,
      itemBuilder: (context, index) {
        final category = dataMap.keys.elementAt(index);
        final amount = dataMap[category]!;
        return ListTile(
          leading: CircleAvatar(backgroundColor: colors[index % colors.length]),
          title: Text(category),
          trailing: Text("฿${amount.toStringAsFixed(2)}"),
        );
      },
    );
  }
}