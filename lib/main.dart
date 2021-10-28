import 'package:flutter/material.dart';
import 'package:quotes/core/service_locator/register_dependencies.dart';
import 'package:quotes/features/quotes/presentation/pages/quotes_page/quotes_page.dart';

import 'core/utilities/show_snack_bar.dart';

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
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}
