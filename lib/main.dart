import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker/HomeWidget.dart';
import 'package:money_tracker/SplashWidget.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() => runApp(Phoenix(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cashtrack',
        theme: CustomTheme.lightTheme,
        darkTheme: CustomTheme.darkTheme,
        themeMode: currentTheme.currentTheme,
        home: MainApp(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => new HomeWidget(parentCtx: context),
          '/splash': (BuildContext context) => new SplashWidget(),
        });
  }
}

class MainApp extends StatefulWidget {
  @override
  State createState() => _MainState();
}

class _MainState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/splash', (Route<dynamic> route) => false);
    }
  }

  Widget build(BuildContext context) {
    new Timer(new Duration(milliseconds: 50), () {
      checkFirstSeen();
    });
    return Scaffold(body: new Container());
  }
}
