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
  bool isLoading = false;
  String? errorMessage;
  int selectedMonth = DateTime.now().month;
  String? selectedCategory;
  final searchController = TextEditingController();
  String searchText = '';

  double monthlyBudget = 5000;
  Map<String, double> categoryBudgets = {};

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  final List<String> categories = ['อาหาร', 'เดินทาง', 'บันเทิง', 'ค่าใช้จ่ายบ้าน', 'อื่นๆ'];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await ApiService.fetchExpenses();
      debugPrint('API result: ' + result.toString());
      if (result != null) {
        setState(() {
          expenses = result;
        });
      } else {
        setState(() {
          errorMessage = 'ไม่สามารถโหลดข้อมูลจาก API';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาด: ' + e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    _checkBudget();
  }

  void _checkBudget() {
    final total = expenses
        .where((e) => e.createdAt?.month == selectedMonth)
        .fold(0.0, (sum, e) => sum + e.amount);
    if (total > monthlyBudget) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('คุณใช้เงินเกินงบเดือนนี้แล้ว!')),
        );
      });
    }
    // แจ้งเตือนเกินงบหมวด
    categoryBudgets.forEach((cat, limit) {
      final catTotal = expenses
          .where((e) => e.category == cat && e.createdAt?.month == selectedMonth)
          .fold(0.0, (sum, e) => sum + e.amount);
      if (limit > 0 && catTotal > limit) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('หมวด $cat เกินงบ!')),
          );
        });
      }
    });
  }

  Future<void> _addExpense() async {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    if (title.isEmpty || amount == null || selectedCategory == null) return;
    final success = await ApiService.addExpense(title, amount, selectedCategory, selectedDate);
    if (success) {
      titleController.clear();
      amountController.clear();
      selectedCategory = null;
      selectedDate = DateTime.now();
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
      if (e.category != null && e.createdAt?.month == selectedMonth) {
        map[e.category!] = (map[e.category!] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Map<int, double> get weeklyTotals {
    final Map<int, double> weekly = {for (int i = 1; i <= 7; i++) i: 0.0};
    for (var e in expenses) {
      if (e.createdAt != null && e.createdAt!.month == selectedMonth) {
        weekly[e.createdAt!.weekday] = (weekly[e.createdAt!.weekday] ?? 0) + e.amount;
      }
    }
    return weekly;
  }

  List<Expense> get filteredExpenses {
    return expenses.where((e) =>
      (selectedCategory == null || e.category == selectedCategory) &&
      (e.title.contains(searchText) || (e.category ?? '').contains(searchText))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredExpenses;
    final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Expense Tracker', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.indigo),
        actions: [
          buildMonthFilter(
            selectedMonth: selectedMonth,
            onMonthChanged: (m) => setState(() => selectedMonth = m),
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: _showBudgetSettings),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gradient shadow effect
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _showAddExpenseForm,
                child: Ink(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F8BFF), Color(0xFF1B3FA6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 40,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _loadExpenses,
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    children: [
                      // Top Card: Budget Summary
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4F8BFF), Color(0xFF1B3FA6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ยอดรวมเดือนนี้', style: TextStyle(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 8),
                            Text(
                              '${total.toStringAsFixed(2)} / $monthlyBudget ฿',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (monthlyBudget > 0) ? (total / monthlyBudget).clamp(0, 1) : 0,
                              backgroundColor: Colors.white24,
                              color: total > monthlyBudget ? Colors.redAccent : Colors.white,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ...ย้าย SearchBar ไปไว้ใต้ Latest Entries...
                      // Overview Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Pie Chart
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: buildPieChart(dataMap),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Analytics Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Weekly Bar Chart
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: buildWeeklyBarChart(weeklyTotals),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Category Filter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ExpenseCategoryFilter(
                          categories: categories,
                          selectedCategory: selectedCategory,
                          onChanged: (cat) => setState(() => selectedCategory = cat),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Latest Entries Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Latest Entries', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // SearchBar (moved here)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ExpenseSearchBar(
                          controller: searchController,
                          onChanged: (val) => setState(() => searchText = val),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Expense List (scrollable in Card)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 320,
                              minHeight: 80,
                            ),
                            child: filtered.isEmpty
                                ? const EmptyState(message: 'ไม่มีข้อมูลในหมวดนี้')
                                : Scrollbar(
                                    radius: const Radius.circular(12),
                                    thickness: 6,
                                    child: ListView.builder(
                                      itemCount: filtered.length,
                                      itemBuilder: (_, i) {
                                        final e = filtered[i];
                                        return Card(
                                          color: Colors.white,
                                          elevation: 0,
                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          child: ListTile(
                                            title: Text(e.title, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
                                            subtitle: Text('${e.category ?? "ไม่ระบุ"}  ${e.createdAt?.toLocal().toString().split(' ')[0] ?? ""}', style: const TextStyle(color: Colors.black54)),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('${e.amount.toStringAsFixed(2)} ฿', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _deleteExpense(e.id),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget buildBudgetSummary() {
    final total = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ยอดรวมเดือนนี้', style: TextStyle(fontSize: 18)),
            Text(
              '${total.toStringAsFixed(2)} / $monthlyBudget ฿',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: total > monthlyBudget ? Colors.red : Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPieChart(Map<String, double> dataMap) {
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
            final color = Colors.primaries[i % Colors.primaries.length];
            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: '${entry.key}\n${entry.value.toStringAsFixed(0)}฿',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }),
        ),
      ),
    );
  }

  Widget buildWeeklyBarChart(Map<int, double> weeklyTotals) {
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

  Widget buildCategoryFilter() {
    final cats = categories;
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text("ทั้งหมด"),
          selected: selectedCategory == null,
          onSelected: (_) => setState(() => selectedCategory = null),
        ),
        ...cats.map((cat) {
          return ChoiceChip(
            label: Text(cat),
            selected: selectedCategory == cat,
            onSelected: (_) => setState(() => selectedCategory = cat),
          );
        }),
      ],
    );
  }

  Widget buildExpenseList(List<Expense> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("ไม่มีรายการในหมวดหมู่นี้", style: TextStyle(color: Colors.grey)),
      );
    }
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 320,
        minHeight: 80,
      ),
      child: Scrollbar(
        radius: const Radius.circular(12),
        thickness: 6,
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final e = list[i];
            return Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(e.title, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
                subtitle: Text('${e.category ?? "ไม่ระบุ"}  ${e.createdAt?.toLocal().toString().split(' ')[0] ?? ""}', style: const TextStyle(color: Colors.black54)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${e.amount.toStringAsFixed(2)} ฿', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteExpense(e.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildMonthFilter({
    required int selectedMonth,
    required Function(int) onMonthChanged,
  }) {
    const monthNames = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return DropdownButton<int>(
      value: selectedMonth,
      items: List.generate(12, (i) => DropdownMenuItem(
        value: i + 1,
        child: Text(monthNames[i]),
      )),
      onChanged: (val) => onMonthChanged(val!),
    );
  }

  void _showAddExpenseForm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('เพิ่มรายจ่าย', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: buildExpenseForm(
            titleController: titleController,
            amountController: amountController,
            selectedCategory: selectedCategory ?? categories.first,
            categories: categories,
            onCategoryChanged: (val) => setState(() => selectedCategory = val),
            selectedDate: selectedDate,
            onDateChanged: (date) => setState(() => selectedDate = date),
            onSave: () {
              Navigator.pop(context);
              _addExpense();
            },
          ),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      ),
    );
  }

  Widget buildExpenseForm({
    required TextEditingController titleController,
    required TextEditingController amountController,
    required String selectedCategory,
    required List<String> categories,
    required Function(String) onCategoryChanged,
    required DateTime selectedDate,
    required Function(DateTime) onDateChanged,
    required VoidCallback onSave,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: "ชื่อรายการ",
            labelStyle: const TextStyle(color: Colors.indigo),
            prefixIcon: const Icon(Icons.edit, color: Colors.indigo),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: "จำนวนเงิน",
            labelStyle: const TextStyle(color: Colors.indigo),
            prefixIcon: const Icon(Icons.attach_money, color: Colors.indigo),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        // Custom ChoiceChip for category selection
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            children: [
              ...categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => onCategoryChanged(cat),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.indigo,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                "วันที่: "+selectedDate.toLocal().toString().split(' ')[0],
                style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.indigo),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime.now(),
                );
                if (picked != null) onDateChanged(picked);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F8BFF), Color(0xFF1B3FA6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onSave,
                splashColor: Colors.white24,
                highlightColor: Colors.white10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save, color: Colors.white, size: 26),
                      SizedBox(width: 10),
                      Text(
                        "บันทึก",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBudgetSettings() {
    final controller = TextEditingController(text: monthlyBudget.toString());
    final Map<String, TextEditingController> catControllers = {
      for (var cat in categories) cat: TextEditingController(text: categoryBudgets[cat]?.toString() ?? '')
    };
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ตั้งงบประมาณ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'งบประมาณเดือนนี้ (บาท)'),
              ),
              const SizedBox(height: 8),
              ...categories.map((cat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: catControllers[cat],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'งบหมวด $cat',
                    border: const OutlineInputBorder(),
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                monthlyBudget = double.tryParse(controller.text) ?? monthlyBudget;
                for (var cat in categories) {
                  final val = double.tryParse(catControllers[cat]!.text) ?? 0;
                  categoryBudgets[cat] = val;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}

class ExpenseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ExpenseSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "ค้นหารายการ",
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Colors.indigo),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// BudgetSummaryCard ไม่จำเป็นอีกต่อไป เพราะย้ายไปอยู่ใน top card gradient แล้ว

class ExpenseCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  const ExpenseCategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text("ทั้งหมด"),
          selected: selectedCategory == null,
          onSelected: (_) => onChanged(null),
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.indigo,
          labelStyle: TextStyle(
            color: selectedCategory == null ? Colors.white : Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
        ...categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) => onChanged(cat),
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.indigo,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
