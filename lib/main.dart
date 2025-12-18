import 'package:flutter/material.dart';
import 'package:graduate/homescreen.dart';
import 'package:graduate/Loginscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      routes: {
      "homescreen":(context) => HomeScreen()},
    );
  }
}
