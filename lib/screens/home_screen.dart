import 'package:expense_tracker_app/models/budget.dart';
import 'package:expense_tracker_app/services/export_service.dart';
import 'package:expense_tracker_app/utils/budget_checker.dart';
import 'package:expense_tracker_app/widgets/monthly_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];

  final titleController = TextEditingController();
  final amountController = TextEditingController();

  final List<String> categories = ['อาหาร', 'เดินทาง', 'บันเทิง', 'ค่าใช้จ่ายบ้าน', 'อื่นๆ'];
  String? selectedCategory = '';

  final Budget monthlyBudget = Budget(month: DateTime.now().month, limit: 5000);

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final result = await ApiService.fetchExpenses();
    if (result != null) {
      setState(() => expenses = result);
    }
    if (isOverBudget(expenses, monthlyBudget)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คุณใช้เงินเกินงบเดือนนี้แล้ว!')),
      );
    }
  }

  Future<void> _addExpense() async {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    if (title.isEmpty || amount == null) return;

    final success = await ApiService.addExpense(title, amount, selectedCategory, DateTime.now());
    if (success) {
      titleController.clear();
      amountController.clear();
      selectedCategory = null;
      _loadExpenses();
    }
  }

  Future<void> _deleteExpense(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันลบ"),
        content: const Text("คุณแน่ใจว่าต้องการลบรายจ่ายนี้หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ลบ", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteExpense(id);
      if (success) _loadExpenses();
    }
  }

  Map<String, double> get dataMap {
    final map = <String, double>{};
    for (var e in expenses) {
      if (e.category != null) {
        map[e.category!] = (map[e.category!] ?? 0) + e.amount;
      }
    }
    return map;
  }

  List<Color> get chartColors => [
        Colors.teal,
        Colors.orange,
        Colors.purple,
        Colors.blue,
        Colors.red,
        Colors.green,
      ];

  double get monthlyTotal {
    final now = DateTime.now();
    return expenses.where((e) => e.createdAt?.month == now.month && e.createdAt?.year == now.year).fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<int, double> calculateMonthlyTotals(List<Expense> expenses) {
    final Map<int, double> monthlyTotals = {
      for (int i = 1; i <= 12; i++) i: 0.0,
    };

    for (var e in expenses) {
      if (e.createdAt != null) {
        final month = e.createdAt!.month;
        monthlyTotals[month] = (monthlyTotals[month] ?? 0) + e.amount;
      }
    }

    return monthlyTotals;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == null
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadExpenses),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChart(),
                  const SizedBox(height: 16),
                  _buildForm(),
                  const SizedBox(height: 16),
                  _buildFilter(),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.4,
                    ),
                    child: _buildExpenseList(filtered),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ยอดรวมเดือนนี้: ${monthlyTotal.toStringAsFixed(2)} ฿',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: MonthlyBarChart(monthlyTotals: calculateMonthlyTotals(expenses)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    final entries = dataMap.entries.toList();
    if (entries.isEmpty) {
      return const Text("ยังไม่มีข้อมูลรายจ่าย", style: TextStyle(color: Colors.grey));
    }

    return AspectRatio(
      aspectRatio: 1.2,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: List.generate(entries.length, (i) {
            final entry = entries[i];
            final color = chartColors[i % chartColors.length];
            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: '${entry.key}\n${entry.value.toStringAsFixed(0)}฿',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }),
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (response == null || response.touchedSection == null) return;
              final index = response.touchedSection!.touchedSectionIndex;
              if (index < 0) return;
              final cat = dataMap.keys.elementAt(index);
              final amt = dataMap.values.elementAt(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$cat: ${amt.toStringAsFixed(2)} ฿')),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: "ชื่อรายการ",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "จำนวนเงิน",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: categories.contains(selectedCategory)
              ? selectedCategory
              : null,
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
          },
          decoration: const InputDecoration(
            labelText: 'หมวดหมู่',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addExpense,
          icon: const Icon(Icons.add),
          label: const Text("เพิ่มรายจ่าย"),
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () async {
            final file = await ExportService.exportExpensesToCsv(expenses);
            if (file != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('บันทึกไฟล์ที่: ${file.path}')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFilter() {
    final categories = dataMap.keys.toList();
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text("ทั้งหมด"),
          selected: selectedCategory == null,
          onSelected: (_) => setState(() => selectedCategory = null),
        ),
        ...categories.map((cat) {
          return ChoiceChip(
            label: Text(cat),
            selected: selectedCategory == cat,
            onSelected: (_) => setState(() => selectedCategory = cat),
          );
        }),
      ],
    );
  }

  Widget _buildExpenseList(List<Expense> list) {
    if (list.isEmpty) {
      return const Text("ไม่มีรายการในหมวดหมู่นี้", style: TextStyle(color: Colors.grey));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final e = list[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(e.title),
            subtitle: Text('${e.category ?? "ไม่ระบุ"}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${e.amount.toStringAsFixed(2)} ฿'),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteExpense(e.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
