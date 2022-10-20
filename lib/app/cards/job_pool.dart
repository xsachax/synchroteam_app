import 'package:flutter/material.dart';
import '../custom_widgets.dart';

class JobPool extends StatefulWidget {
  @override
  _JobPoolState createState() => _JobPoolState();
}

class _JobPoolState extends State<JobPool> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0.0,
            title: backToSomewhere(context, 'Home', '/main'),
            bottom: PreferredSize(
                child: Container(
                  color: Colors.black,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(0))),
        body: Center(child: Text('Job Pool')));
  }
}
