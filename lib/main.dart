import 'package:expense_tracker_app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      builder: (context, _) {
        final isDark = context.watch<ThemeProvider>().isDark;
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: HomeScreen(
            expenses: [
              Expense(id: 1, title: "ข้าว", amount: 50, category: "อาหาร"),
              Expense(id: 2, title: "กาแฟ", amount: 60, category: "อาหาร"),
              Expense(id: 3, title: "รถไฟฟ้า", amount: 30, category: "เดินทาง"),
              Expense(id: 4, title: "หนังสือ", amount: 100, category: "การศึกษา",),
            ],
          ),
        );
      },
    );
  }
}
