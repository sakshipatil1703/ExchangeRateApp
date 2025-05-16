import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
