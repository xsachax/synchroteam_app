import 'package:flutter/material.dart';
import '../custom_widgets.dart';

class PartsInventory extends StatefulWidget {
  @override
  _PartsInventoryState createState() => _PartsInventoryState();
}

class _PartsInventoryState extends State<PartsInventory> {
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
        body: Center(child: Text('Parts Inventory')));
  }
}