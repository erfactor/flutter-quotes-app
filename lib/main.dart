import 'package:flutter/material.dart';
import 'package:netguru/pages/home_page.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
    title: 'Netguru Core Values',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    darkTheme: ThemeData.dark(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 1,
      navigateAfterSeconds: HomePage(),
      image: new Image.asset("assets/images/netguru.png"),
      backgroundColor: Colors.black12,
      photoSize: 100.0,
      loaderColor: Colors.transparent,
      routeName: "/x",
    );
  }
}
