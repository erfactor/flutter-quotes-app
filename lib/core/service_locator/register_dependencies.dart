import 'package:quotes/core/service_locator/sl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future registerDependencies() async {
  sl.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
}
