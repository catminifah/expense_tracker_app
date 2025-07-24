import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

class ApiService {
  static const baseUrl = 'https://expense-server-iqv1.onrender.com/expenses';

  static Future<List<Expense>?> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      print('Fetch status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        print('Fetch data count: ${jsonData.length}');
        return jsonData.map((e) => Expense.fromJson(e)).toList();
      } else {
        print('Fetch failed: ${response.body}');
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
    return null;
  }

  static Future<bool> addExpense(
    String title,
    double amount,
    String? category,
    DateTime date,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'amount': amount,
          'category': category,
          'created_at': date.toIso8601String(),
        }),
      );
      print('Add status code: ${response.statusCode}');
      print('Add response body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  static Future<bool> deleteExpense(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      print('Delete status code: ${response.statusCode}');
      print('Delete response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }

  static Future<bool> updateExpense(
    int id,
    String title,
    double amount,
    String? category,
    DateTime date,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'amount': amount,
          'category': category,
          'created_at': date.toIso8601String(),
        }),
      );
      print('Update status code: ${response.statusCode}');
      print('Update response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating expense: $e');
      return false;
    }
  }
}