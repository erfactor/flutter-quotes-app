import 'package:flutter/material.dart';
import 'package:netguru/pages/home_page.dart';

void main() {
  runApp(TheApp());
}

class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Netguru Core Values',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
