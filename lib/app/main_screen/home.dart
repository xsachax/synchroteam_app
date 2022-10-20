import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../AppTheme.dart';
import '../custom_widgets.dart';
import '../cards/messages.dart';

// CARDS
import '../cards/job_pool.dart';
import '../cards/customers.dart';
import '../cards/parts_inventory.dart';
import '../cards/documents.dart';
import '../cards/calendarFolder/calendar.dart';

class Home extends StatefulWidget {
/*
  Home(this.late, this.tday, this.upcoming);
 
 int late;
  int tday;
  int upcoming;
*/
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List mainMenuOptions = [
    'Job Pool',
    'Customers',
    'Parts Inventory',
    'Documents',
    'Messages'
  ];

  DateTime now = new DateTime.now();
  DateFormat formatter = DateFormat.yMMMMd('en_US');

  int late = 2;
  int tday = 0;
  int upcoming = 0;

  _jobPool() => {
        Navigator.of(context).push(MaterialPageRoute<void>(
            settings: RouteSettings(name: "/jobPool"),
            builder: (BuildContext context) {
              return JobPool();
            }))
      };
  _customers() => {
        Navigator.of(context).push(MaterialPageRoute<void>(
            settings: RouteSettings(name: "/customers"),
            builder: (BuildContext context) {
              return Customers();
            }))
      };
  _partsInventory() => {
        Navigator.of(context).push(MaterialPageRoute<void>(
            settings: RouteSettings(name: "/partsInventory"),
            builder: (BuildContext context) {
              return PartsInventory();
            }))
      };
  _documents() => {
        Navigator.of(context).push(MaterialPageRoute<void>(
            settings: RouteSettings(name: "/documents"),
            builder: (BuildContext context) {
              return Documents();
            }))
      };
  _messages() => {
        Navigator.of(context).push(MaterialPageRoute<void>(
            settings: RouteSettings(name: "/messages"),
            builder: (BuildContext context) {
              return Messages();
            }))
      };

  onTapFunctions(pos) {
    if (pos == 0) {
      _jobPool();
    }
    if (pos == 1) {
      _customers();
    }
    if (pos == 2) {
      _partsInventory();
    }
    if (pos == 3) {
      _documents();
    }
    if (pos == 4) {
      _messages();
    }
  }

  Color _myWorkColor;
  _myWorkColorGenerator() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == Brightness.dark
        ? _myWorkColor = Colors.white.withOpacity(0.1)
        : _myWorkColor = Colors.white.withOpacity(0.6);
    return _myWorkColor;
  }

  @override
  Widget build(BuildContext context) {
    // HOME
    return Scaffold(
      appBar: AppBar(
        title: Container(
            child: Image.asset('images/st_1.png', width: 170, height: 60)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () => {},
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
            child: Text("John's Widgets Inc.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            decoration: BoxDecoration(
              color: companyOrange,
              shape: BoxShape.rectangle,
            ),
            alignment: Alignment.center,
            height: 35,
            width: 600,
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0)),
        InkWell(
            onTap: () => {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      settings: RouteSettings(name: "/calendar"),
                      builder: (BuildContext context) {
                        return Calendar();
                      }))
                },
            child: Column(children: [
              Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
                  margin: EdgeInsets.fromLTRB(10.0, 10, 10.0, 0),
                  alignment: Alignment.center,
                  child: Column(children: [
                    Text('My Work',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold)),
                    Text(formatter.format(now),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  decoration: BoxDecoration(
                    color: _myWorkColorGenerator(),
                    border: Border.all(color: _myWorkColorGenerator()),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    shape: BoxShape.rectangle,
                  )),
              Container(
                child: Row(children: [
                  HomePageCounterButton.get(
                      'Late',
                      late,
                      Colors.red[600],
                      Colors.red[400],
                      (MediaQuery.of(context).size.width / 3 - (5 + (5 / 3))),
                      1),
                  HomePageCounterButton.get(
                      'Today',
                      tday,
                      Colors.green,
                      Colors.greenAccent[400],
                      (MediaQuery.of(context).size.width / 3 - (5 + (5 / 3))),
                      2),
                  HomePageCounterButton.get(
                      'Upcoming',
                      upcoming,
                      Colors.grey[600],
                      Colors.grey[400],
                      (MediaQuery.of(context).size.width / 3 - (5 + (5 / 3))),
                      3)
                ]),
                decoration: BoxDecoration(),
                alignment: Alignment.center,
                height: 80,
                margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10),
              ),
            ])),
        Container(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, pos) {
                  return Card(
                      child: new InkWell(
                          onTap: () {
                            onTapFunctions(pos);
                          },
                          child: ListTile(
                              title: Text(mainMenuOptions[pos],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              trailing: Icon(Icons.chevron_right))));
                }))
      ])),
    );
  }
}
