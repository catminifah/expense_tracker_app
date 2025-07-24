import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final controller = TextEditingController();
  final Map<String, TextEditingController> catControllers = {
    'อาหาร': TextEditingController(),
    'เดินทาง': TextEditingController(),
    'บันเทิง': TextEditingController(),
    'ค่าใช้จ่ายบ้าน': TextEditingController(),
    'อื่นๆ': TextEditingController(),
  };
  double used = 3200; // ตัวอย่างยอดใช้จ่ายเดือนนี้
  double budget = 5000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('ตั้งงบประมาณ', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.indigo),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analytics',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('งบประมาณรวมเดือนนี้', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ใส่งบประมาณ (บาท)',
                labelStyle: TextStyle(color: Colors.indigo),
                prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.indigo),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (used / (double.tryParse(controller.text) ?? budget)).clamp(0, 1),
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: used > (double.tryParse(controller.text) ?? budget) ? Colors.red : Colors.indigo,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('ใช้ไป $used / ${controller.text.isEmpty ? budget : controller.text} บาท',
                  style: TextStyle(
                    color: used > (double.tryParse(controller.text) ?? budget) ? Colors.red : Colors.indigo,
                  )),
            ),
            const Divider(height: 32),
            const Text('งบประมาณแต่ละหมวด', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            ...catControllers.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: e.value,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.indigo),
                decoration: InputDecoration(
                  labelText: 'งบหมวด ${e.key}',
                  labelStyle: const TextStyle(color: Colors.indigo),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category, color: Colors.indigo),
                ),
              ),
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // save logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('บันทึกงบประมาณสำเร็จ')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('บันทึก'),
            ),
            TextButton(
              onPressed: () {
                controller.clear();
                for (var c in catControllers.values) {
                  c.clear();
                }
                setState(() {});
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('รีเซ็ตทั้งหมด'),
            ),
          ],
        ),
      ),
    );
  }
}