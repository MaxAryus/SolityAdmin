import 'dart:convert';
import 'package:SolityAdmin/tabController.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController etUsername = new TextEditingController();
  TextEditingController etPassword = new TextEditingController();

  String nUsername = "";
  String nPassword = "";

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 30,
            color: Colors.white,
          ),
          Image.asset(
            'assets/images/banner.jpg',
            width: _width + 20,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                WelcomHeader(),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Form(
                    // key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: etUsername,
                          decoration: InputDecoration(
                            labelText: 'Benutzername',
                            hintText: "Geben Sie hier Ihren Benutzernamen ein",
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: etPassword,
                          decoration: InputDecoration(
                            labelText: 'Passwort',
                            hintText: 'Geben Sie hier Ihr Passwort ein',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        MaterialButton(
                          color: Color(0xFF8DD1FF),
                          child: Text(
                            'Anmelden',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF081031),
                            ),
                          ),
                          onPressed: () async {
                            if (await login() == null) {
                              Navigator.pushReplacement(
                                context,
                                new PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => new Login(),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              );
                            } else if (await login() != null) {
                              Navigator.pushReplacement(
                                context,
                                new PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      new HomeController(),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future login() async {
    var email = etUsername.text.trim().toString();
    var password = etPassword.text.trim().toString();
    http.Response response =
        await http.post('https://api.go-omi.com/adminLogin', headers: {
      'Accept': 'application/json',
    }, body: {
      'email': '${email}',
      'password': '${password}',
    });

    var body = response.body;

    var id = jsonDecode(body)['adminID'];
    var token = jsonDecode(body)['response']['original']['token'];

    if (token != null) {
      var firstname =
          jsonDecode(body)['response']['original']['user']['first_name'];
      var lastname =
          jsonDecode(body)['response']['original']['user']['last_name'];

      final prefs = await SharedPreferences.getInstance();

      prefs.setString('firstname', firstname);
      prefs.setString('lastname', lastname);
      prefs.setString('token', token);
      prefs.setInt('id', id);

      return token;
    } else {
      return null;
    }
  }
}

class WelcomHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            'Willkommen',
            style: TextStyle(
              fontSize: 28,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
