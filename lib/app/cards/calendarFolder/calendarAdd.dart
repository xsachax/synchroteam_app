import 'package:flutter/material.dart';

class CalendarAdd extends StatefulWidget {


  const CalendarAdd({Key key, this.jobs}) : super(key: key);

  final jobs;

  @override
  _CalendarAddState createState() => _CalendarAddState();
}

class _CalendarAddState extends State<CalendarAdd> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Add'));
  }
}
