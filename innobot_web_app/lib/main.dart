// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/user_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
