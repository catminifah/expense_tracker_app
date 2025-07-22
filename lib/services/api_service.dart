import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

class ApiService {
  static const baseUrl = 'https://your-api-domain.com/expenses';

  static Future<List<Expense>?> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        return jsonData.map((e) => Expense.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
    return null;
  }

  static Future<bool> addExpense(String title, double amount, String? category) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'amount': amount,
          'category': category,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  static Future<bool> deleteExpense(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }
}