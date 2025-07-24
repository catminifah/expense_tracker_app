import 'package:expense_tracker_app/models/budget.dart';
import 'package:expense_tracker_app/models/expense.dart';

bool isOverBudget(List<Expense> expenses, Budget budget) {
  final total = expenses
      .where((e) => e.createdAt?.month == budget.month)
      .fold(0.0, (sum, e) => sum + e.amount);

  return total > budget.limit;
}
