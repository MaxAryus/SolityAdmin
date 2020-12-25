import 'dart:convert';

import 'package:SolityAdmin/homepage.dart';
import 'package:SolityAdmin/tabController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class AddEvent extends StatefulWidget {
  AddEvent({Key key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController etEventName = new TextEditingController();
  TextEditingController etBeginning = new TextEditingController();
  TextEditingController etEnd = new TextEditingController();
  TextEditingController etDescription = new TextEditingController();
  TextEditingController etDate = new TextEditingController();

  String dropdownValue = 'Montag';
  String dropdownNumber = '4';
  String evetnType = 'Lesungen';
  String serverAnswer = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: etEventName,
                decoration: InputDecoration(
                  labelText: 'Neuer Eventname',
                  hintText: "Geben Sie hier den Namen für das Event ein",
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
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(
                      'Wochentag auswählen:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(
                      Icons.arrow_downward,
                      color: Colors.black,
                    ),
                    iconSize: 20,
                    elevation: 16,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>[
                      'Montag',
                      'Dienstag',
                      'Mittwoch',
                      'Donnerstag',
                      'Freitag',
                      'Samstag',
                      'Sonntag'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              TextFormField(
                controller: etDate,
                decoration: InputDecoration(
                  labelText: 'Datum',
                  hintText: "z.B.: 11.11.2020",
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
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextFormField(
                      controller: etBeginning,
                      decoration: InputDecoration(
                        labelText: 'Beginn',
                        hintText: "z.B.: 17:00",
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
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4.5,
                    child: Center(
                      child: CardTitle(
                        title: '-',
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextFormField(
                      controller: etEnd,
                      decoration: InputDecoration(
                        labelText: 'Ende',
                        hintText: "z.B.: 18:30",
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
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2.6,
                    child: Text(
                      'Anzahl an maximalen Teilnehmern:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    // width: MediaQuery.of(context).size.width / 2.6,
                    child: DropdownButton<String>(
                      value: this.dropdownNumber,
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Colors.black,
                      ),
                      iconSize: 20,
                      elevation: 16,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownNumber = newValue;
                        });
                      },
                      items: <String>['4']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Text(
                      'Eventtyp auswählen',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: DropdownButton<String>(
                      value: this.evetnType,
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Colors.black,
                      ),
                      iconSize: 20,
                      elevation: 16,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          evetnType = newValue;
                        });
                      },
                      items: <String>[
                        'Lesungen',
                        'Quiz',
                        'Stammtisch',
                        'Witzerunde',
                        'Gedächtnistraining'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: etDescription,
                decoration: InputDecoration(
                  labelText: 'Beschreibung',
                  hintText: "Geben Sie hier eine Kurze Beschrebung an",
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
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  MaterialButton(
                    color: Color(0xFF8DD1FF),
                    child: Text(
                      'Event erstellen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF081031),
                      ),
                    ),
                    onPressed: () async {
                      if (etEventName.text.trim().isNotEmpty &&
                          etDate.text.trim().isNotEmpty &&
                          etBeginning.text.trim().isNotEmpty &&
                          etEnd.text.trim().isNotEmpty &&
                          etDescription.text.trim().isNotEmpty) {
                        await createEvent();
                      } else {
                        setState(() {
                          serverAnswer =
                              "Es sind nicht alle Felder Ausgefüllt!";
                        });
                      }
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        etEventName.clear();
                        etBeginning.clear();
                        etEnd.clear();
                        etDescription.clear();
                        etDate.clear();
                      });
                    },
                    color: Color(0xFF8DD1FF),
                    child: Text(
                      'Aufräumen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF081031),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '$serverAnswer',
                softWrap: true,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future createEvent() async {
    var eventName = etEventName.text.trim().toString();
    var date = etDate.text.trim().toString();
    var beginning = etBeginning.text.trim().toString();
    var ending = etEnd.text.trim().toString();
    var cat = _getEventNumber();
    var description = etDescription.text.trim().toString();

    http.Response response =
        await http.post('https://api.go-omi.com/createEvent', headers: {
      'Accept': 'application/json',
    }, body: {
      'event_name': '$eventName',
      'day': '$dropdownValue',
      'date': '$date',
      'beginning': '$beginning',
      'ending': '$ending',
      'number_of_maximal_members': '$dropdownNumber',
      'moderator': '1',
      'event_type': '0',
      'event_category': '$cat',
      'description': '$description'
    });

    setState(() {
      serverAnswer = jsonDecode(response.body)['message'];
    });
  }

  int _getEventNumber() {
    var event_type = 0;

    switch (evetnType) {
      case 'Lesungen':
        return event_type = 1;
      case 'Quiz':
        return event_type = 2;
      case 'Stammtisch':
        return event_type = 3;
      case 'Witzerunde':
        return event_type = 4;
      case 'Gedächtnistraining':
        return event_type = 5;
    }
  }
}
