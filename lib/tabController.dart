import 'package:SolityAdmin/addTab.dart';
import 'package:SolityAdmin/calltab.dart';
import 'package:SolityAdmin/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class HomeController extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeControllerState();
  }
}

class _HomeControllerState extends State<HomeController> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
    // CallList(),
    AddEvent(),
  ];

  String firstname;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi $firstname!'),
        leading: GestureDetector(
          onTap: () async {
            var prefs = await SharedPreferences.getInstance();
            prefs.setString('token', null);
            Navigator.pushReplacement(
              context,
              new PageRouteBuilder(
                pageBuilder: (_, __, ___) => new Login(),
                transitionDuration: Duration(seconds: 0),
              ),
            );
          },
          child: Icon(Icons.logout),
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        fixedColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            title: Text('Home'),
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.people_outline,
          //   ),
          //   title: Text('Live'),
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
            ),
            title: Text('Neues Event'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future getName() async {
    var prefs = await SharedPreferences.getInstance();

    setState(() {
      this.firstname = prefs.getString('firstname');
    });
  }
}
