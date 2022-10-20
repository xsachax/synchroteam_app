import 'package:flutter/material.dart';
import '../custom_widgets.dart';


class Documents extends StatefulWidget {
  @override
  _DocumentsState createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
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
        body: Center(child: Text('Documents')));
  
  }
}
