import 'dart:convert';

import 'package:SolityAdmin/callScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var heightAppBar = AppBar().preferredSize.height + 20;

  List event_names = [];
  List beginnings = [];
  List endings = [];
  List dates = [];
  List eventIds = [];
  List categories = [];
  List roomIds = [];

  List category = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: Color(0xFF4ED898),
        onRefresh: () async {
          setState(() {
            this.getEventsForList();
          });
        },
        child: Container(
          height: MediaQuery.of(context).size.height - heightAppBar,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                future: this.getEventsForList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Color(0xFF4ED898)),
                      ),
                    );
                  } else {
                    return new Expanded(
                      child: new ListView.builder(
                        itemCount: this.event_names.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return AktivityCardLive(
                            title: this.event_names[index],
                            beginning: this.beginnings[index],
                            ending: this.endings[index],
                            date: this.dates[index],
                            eventId: this.eventIds[index],
                            category: this.categories[index],
                            roomId: this.roomIds[index],
                          );
                        },
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getEventsForList() async {
    http.Response events = await http.get(
      'https://api.go-omi.com/getAllEvents',
    );

    beginnings.clear();
    event_names.clear();
    endings.clear();
    dates.clear();
    eventIds.clear();
    categories.clear();

    var body = events.body;

    var bodyLenght = jsonDecode(body);
    bodyLenght = bodyLenght.length;

    var ending = jsonDecode(body)[0]['ending'];

    for (int i = 0; i < bodyLenght; i++) {
      if (this.category.isNotEmpty) {
        var cat = jsonDecode(body)[i]['event_category'];
        if (category.contains(cat)) {
          var event_name = jsonDecode(body)[i]['event_name'];
          event_name = event_name as String;
          this.event_names.add(event_name.toString());

          var beginning = jsonDecode(body)[i]['beginning'];
          beginning = beginning as String;
          this.beginnings.add(beginning.toString());

          var ending = jsonDecode(body)[i]['ending'];
          ending = ending as String;
          this.endings.add(beginning.toString());

          var date = jsonDecode(body)[i]['day'];
          date = date as String;
          this.dates.add(date.toString());

          var category = jsonDecode(body)[i]['event_category'];
          this.categories.add(category);

          var id = jsonDecode(body)[i]['id'];
          this.eventIds.add(id);

          var roomId = jsonDecode(body)[i]['roomID'];
          roomId = roomId as String;
          this.roomIds.add(roomId);
        }
      } else {
        var event_name = jsonDecode(body)[i]['event_name'];
        event_name = event_name as String;
        this.event_names.add(event_name.toString());

        var beginning = jsonDecode(body)[i]['beginning'];
        beginning = beginning as String;
        this.beginnings.add(beginning.toString());

        var ending = jsonDecode(body)[i]['ending'];
        ending = ending as String;

        this.endings.add(ending.toString());

        var date = jsonDecode(body)[i]['day'];
        date = date as String;
        this.dates.add(date.toString());

        var category = jsonDecode(body)[i]['event_category'];
        this.categories.add(category);

        var id = jsonDecode(body)[i]['id'];
        this.eventIds.add(id);

        var roomId = jsonDecode(body)[i]['roomID'];
        roomId = roomId as String;
        this.roomIds.add(roomId);
      }
    }

    return event_names;
  }
}

class AktivityCardLive extends StatelessWidget {
  const AktivityCardLive(
      {this.title,
      this.beginning,
      this.ending,
      this.date,
      this.eventId,
      this.category,
      this.roomId});

  final String title;

  final String beginning;
  final String ending;
  final String date;
  final int eventId;
  final int category;
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 345,
      // height: 352,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Container(
          width: 345,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF000000).withOpacity(0.01),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildImage(context, category),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    CardTitle(
                      title: this.title,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "$date    $beginning - $ending",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        EventTypeIndicator(),
                        SizedBox(
                          width: 10,
                        ),
                        StartEvent(
                          eventId: this.eventId,
                          roomId: this.roomId,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildImage(BuildContext context, id) {
    switch (id) {
      case 1:
        return Container(
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              'assets/images/lesen-mini.png',
              // scale: 0.4,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );
      case 2:
        return Container(
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              'assets/images/quiz-mini.png',
              // scale: 0.4,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );

      case 3:
        return Container(
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              'assets/images/stammtisch-min.png',
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );

      case 4:
        return Container(
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              'assets/images/witzerunde-mini.png',
              // scale: 0.4,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );

      case 5:
        return Container(
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              'assets/images/gedächtnistraining-mini.png',
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );
        break;
      default:
    }
  }
}

class EventTypeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      // width: 183,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: Color(0xFFF1F4F9)),
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 23,
              color: Color(0xFF4EAAD8),
            ),
            SizedBox(
              width: 9,
            ),
            Text(
              'Virtuelles Event',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4EAAD8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardTitle extends StatelessWidget {
  const CardTitle({this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      this.title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.left,
    );
  }
}

class StartEvent extends StatefulWidget {
  StartEvent({Key key, this.eventId, this.roomId}) : super(key: key);
  final eventId;
  final roomId;

  @override
  _StartEventState createState() => _StartEventState();
}

class _StartEventState extends State<StartEvent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _handleCameraAndMic(Permission.camera);
        await _handleCameraAndMic(Permission.microphone);

        await setEventLive();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreeb(
              roomID: widget.roomId,
              eventID: widget.eventId,
            ),
          ),
        );
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            color: Theme.of(context).primaryColor.withOpacity(0.6)),
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.black,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Beginnen',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future setEventLive() async {
    var id = widget.eventId;
    http.Response response =
        await http.post('https://api.go-omi.com/setEventLive', body: {
      'id': '$id',
    });
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
  }
}
