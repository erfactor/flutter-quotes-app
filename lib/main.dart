import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quotes/core/service_locator/register_dependencies.dart';

import 'app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerDependencies();
  FlutterError.onError = onFlutterError;
  runZonedGuarded<Future<void>>(
    () async => runApp(const App()),
    (error, stackTrace) {
      if (kReleaseMode) {
        // sentry, crashlytics
      } else {
        debugPrintSynchronously('Caught an exception\n$error\n $stackTrace');
      }
    },
  );
}

void onFlutterError(FlutterErrorDetails details) {
  if (kReleaseMode) {
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
  } else {
    FlutterError.dumpErrorToConsole(details);
  }
}
