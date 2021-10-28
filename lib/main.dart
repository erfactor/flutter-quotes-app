import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/service_locator/register_dependencies.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';
import 'package:quotes/features/quotes/presentation/pages/quotes_page/quotes_page.dart';

import 'core/utilities/show_snack_bar.dart';

void main() {
  registerDependencies();
  runApp(TheApp());
}

class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (_) => QuoteRepository())],
      child: MaterialApp(
        title: 'Quotes App',
        theme: ThemeData(primarySwatch: Colors.green),
        darkTheme: ThemeData.dark(),
        home: QuotesPage(),
        scaffoldMessengerKey: scaffoldMessengerKey,
      ),
    );
  }
}
