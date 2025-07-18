import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    expenses = (await ApiService.fetchExpenses())!;
    print('Loaded expenses: ${expenses.length}');
    setState(() {});
  }

  Future<void> addExpense() async {
    
    final title = titleController.text;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'ชื่อรายการ')),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'จำนวนเงิน')),
              DropdownButton<String>(
                value: category,
                onChanged: (val) => setState(() => category = val!),
                items: ['อาหาร', 'เดินทาง', 'อื่นๆ']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
              ElevatedButton(onPressed: addExpense, child: const Text('เพิ่มรายการ')),
            ]),
          ),
          Expanded(child: ExpenseList(expenses: expenses)),
        ],
      ),
    );
  }
}
