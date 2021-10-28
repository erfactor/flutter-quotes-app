import 'package:flutter/material.dart';
import 'package:quotes/core/register_dependencies.dart';
import 'package:quotes/features/quotes/presentation/pages/home_page.dart';

void main() {
  registerDependencies();
  runApp(TheApp());
}

class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotes App',
      theme: ThemeData(primarySwatch: Colors.green),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
