import 'package:SolityAdmin/login.dart';
import 'package:SolityAdmin/tabController.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xFF4ED898), // Green
        accentColor: Color(0xFF4EAAD8), // Blue
      ),
      home: FutureBuilder(
        future: check(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Login();
          } else {
            return HomeController();
          }
        },
      ),
    );
  }

  Future check() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    if (token != null) {
      return true;
    } else {
      return null;
    }
  }
}
