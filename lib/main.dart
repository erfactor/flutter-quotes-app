import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quotes/core/service_locator/register_dependencies.dart';
import 'package:quotes/features/quotes/data/repository/quotes_repository.dart';
import 'package:quotes/features/quotes/presentation/pages/quotes_page/quotes_page.dart';

import '../core/utilities/show_snack_bar.dart';

void main() {
  registerDependencies();
  FlutterError.onError = onFlutterError;
  runZonedGuarded<Future<void>>(
    () async => runApp(TheApp()),
    (error, stackTrace) {
      debugPrintSynchronously('Caught an exception\n$error\n $stackTrace');
    },
  );
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

void onFlutterError(FlutterErrorDetails details) {
  if (kReleaseMode) {
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
  } else {
    FlutterError.dumpErrorToConsole(details);
  }
}
