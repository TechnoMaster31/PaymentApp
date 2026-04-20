import 'package:flutter/material.dart';
import 'screens/product_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      debugShowCheckedModeBanner: true,
      theme: ThemeData.dark(useMaterial3: true),
      home: const ProductPage(),
    );
  }
}
