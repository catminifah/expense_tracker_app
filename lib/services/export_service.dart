import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/expense.dart';

class ExportService {
  static Future<File?> exportExpensesToCsv(List<Expense> expenses) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return null;

    final rows = <List<String>>[
      ['ID', 'Title', 'Amount', 'Category', 'Created At'],
      ...expenses.map((e) => [
            e.id.toString(),
            e.title,
            e.amount.toStringAsFixed(2),
            e.category ?? '',
            e.createdAt?.toIso8601String() ?? '',
          ]),
    ];

    final String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/expenses.csv');

    await file.writeAsString(csvData);
    return file;
  }
}
