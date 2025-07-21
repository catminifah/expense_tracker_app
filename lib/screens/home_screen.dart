import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../../services/api_service.dart';
import '../../widgets/expense_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String category = 'อาหาร';

  Future<void> loadData() async {
    expenses = (await ApiService.fetchExpenses()) ?? [];
    setState(() {});
  }

  Future<void> addExpense() async {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text) ?? 0;
    if (title.isEmpty || amount <= 0) return;

    await http.post(
      Uri.parse('http://192.168.4.170:3000/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'amount': amount, 'category': category}),
    );

    await ApiService.addExpense(title, amount, category);
    titleController.clear();
    amountController.clear();
    await loadData();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void showAddExpenseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "เพิ่มรายการใหม่",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'ชื่อรายการ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'จำนวนเงิน',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              items: ['อาหาร', 'เดินทาง', 'อื่นๆ']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await addExpense();
              },
              icon: const Icon(Icons.check),
              label: const Text("บันทึกรายการ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCard() {
    double total = expenses.fold(0, (sum, e) => sum + e.amount);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.account_balance_wallet, color: Colors.redAccent, size: 30),
                SizedBox(width: 12),
                Text("รวมรายจ่ายเดือนนี้", style: TextStyle(fontSize: 16)),
              ],
            ),
            Text(
              "฿${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // สมมติ Expense มี property DateTime? date
  Map<int, double> getDailyExpenses() {
    Map<int, double> dailyTotals = {};
    for (var e in expenses) {
      int day = e.date?.day ?? 1;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + e.amount;
    }
    return dailyTotals;
  }

  Widget buildExpenseChart() {
    final dailyExpenses = getDailyExpenses();

    if (dailyExpenses.isEmpty) {
      return const Center(child: Text('ไม่มีข้อมูลกราฟ'));
    }

    double maxY = 10.0;
    if (dailyExpenses.isNotEmpty) {
      maxY = dailyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2;
      if (maxY.isNaN || maxY.isInfinite) maxY = 10.0;
    }

    List<FlSpot> spots = dailyExpenses.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: true),
              minX: spots.first.x,
              maxX: spots.last.x,
              minY: 0,
              maxY: maxY,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(value.toInt().toString()),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.indigo,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/profile.jpg'), // เปลี่ยนเป็นรูปโปรไฟล์จริงของคุณ
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('สวัสดี, ผู้ใช้', style: theme.textTheme.titleMedium),
                    Text('วันนี้คุณใช้จ่ายไปเท่าไร?', style: theme.textTheme.bodyMedium),
                  ],
                )
              ],
            ),
          ),

          // Summary Card
          buildSummaryCard(),

          // Chart
          buildExpenseChart(),

          // รายการรายจ่าย
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RefreshIndicator(
                onRefresh: loadData,
                child: expenses.isEmpty
                    ? Center(child: Text("ยังไม่มีรายการ", style: theme.textTheme.bodyMedium))
                    : ExpenseList(expenses: expenses),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddExpenseBottomSheet,
        icon: const Icon(Icons.add),
        label: const Text("เพิ่มรายการ"),
        backgroundColor: Colors.indigo,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.indigo,
        onTap: (i) {
          // TODO: เพิ่มการนำทาง
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าหลัก"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "สรุป"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "ตั้งค่า"),
        ],
      ),
    );
  }
}
