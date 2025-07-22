import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final data = await ApiService.fetchExpenses();
    if (data != null) {
      setState(() {
        expenses = data;
        isLoading = false;
      });
    }
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
                await ApiService.addExpense(title, double.parse(amount), category);
                Navigator.pop(context);
                loadExpenses();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense e) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        title: Text(e.title),
        subtitle: Text(e.category ?? 'ไม่มีหมวดหมู่'),
        trailing: Text(
          '- ${e.amount.toStringAsFixed(2)} ฿',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onLongPress: () => _deleteExpense(e.id as int),
      ),
    );
  }

  void _deleteExpense(int id) async {
    await ApiService.deleteExpense(id);
    loadExpenses();
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
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "รวมรายจ่ายเดือนนี้",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${getTotalAmount().toStringAsFixed(2)} ฿",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: expenses.isEmpty
                      ? const Center(child: Text("ยังไม่มีข้อมูลรายจ่าย"))
                      : ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (_, i) => _buildExpenseCard(expenses[i]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
