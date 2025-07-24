import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.indigo,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(primary: Colors.indigo),
      ),
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
    );
  }
}

// https://console.neon.tech/app/projects/wispy-unit-06899464/branches/br-royal-darkness-a1f1kn5h/sql-editor?database=neondb
// https://dashboard.render.com/web/srv-d1uv7ridbo4c73f0ftd0/deploys/dep-d1vla3re5dus739t3gcg