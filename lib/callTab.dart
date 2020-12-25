import 'package:flutter/material.dart';

class CallList extends StatefulWidget {
  @override
  _CallListState createState() => _CallListState();
}

class _CallListState extends State<CallList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.green,
    );
  }
}
