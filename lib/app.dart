import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/utilities/show_snack_bar.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';
import 'package:quotes/features/quotes/presentation/pages/main_page/quotes_main_page.dart';

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (_) => QuoteRepository())],
      child: MaterialApp(
        title: 'Quotes App',
        theme: ThemeData(primarySwatch: Colors.green),
        darkTheme: ThemeData.dark(),
        home: QuotesMainPage(),
        scaffoldMessengerKey: scaffoldMessengerKey,
      ),
    );
  }
}
