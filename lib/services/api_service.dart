import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

class ApiService {
  static const baseUrl = 'https://expense-server-iqv1.onrender.com';

  static Future<List<Expense>?> fetchExpenses() async {
    final response = await http.get(Uri.parse("$baseUrl/expenses"));
    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      print('Loaded expenses JSON: ${response.body}');
      return jsonData.map((e) => Expense.fromJson(e)).toList();
    } else {
      print("Error ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception('Failed to load');
    }
  }

  static Future<void> addExpense(String title, double amount, String category) async {
    await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'amount': amount, 'category': category}),
    );
  }
}
