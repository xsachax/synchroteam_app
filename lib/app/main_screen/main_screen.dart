import 'package:flutter/material.dart';
import './home.dart';
import './settings.dart';
import './logout.dart';
/*
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
*/

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List <Widget> tabs = [Settings(), Home(), Logout()];
  int late = 0;
  int tday = 0;
  int upcoming = 0;
  DateTime now = new DateTime.now();


@override
  Widget build(BuildContext context) {
    return Scaffold(
        body: tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.shifting,
            items: [
              BottomNavigationBarItem(
                  icon: new Icon(Icons.settings), label: 'Settings'),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.logout), label: 'Logout'),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            }));
  }
}
