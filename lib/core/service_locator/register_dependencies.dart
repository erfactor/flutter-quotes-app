import 'package:quotes/core/service_locator/sl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void registerDependencies() {
  sl.registerLazySingleton(() async => await SharedPreferences.getInstance());
}
