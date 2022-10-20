import 'package:flutter/material.dart';
import '../../custom_widgets.dart';
import './calendarSearch.dart';
import './calendarMain.dart';
import '../../AppTheme.dart';
import './calendarAdd.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  int pageIndex = 0;
  List pages = [CalendarMain(), CalendarAdd(), CalendarSearch()];

  buildBottomBar() {
    return BottomAppBar(
        color: Colors.transparent,
        elevation: 1,
        child: InkWell(
          onTap: () => {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.red),
                  child:
                      Icon(Icons.access_time, size: 32, color: Colors.white)),
              SizedBox(width: 100, height: 50),
              Container(
                width: 50,
                height: 50,
                child: Icon(Icons.play_arrow_rounded,
                    size: 32, color: Colors.white),
                padding: EdgeInsets.all(5),
              ),
              Container(
                  child: Text(
                'Start',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ))
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0.0,
            title: backToSomewhere(context, 'Home', '/main'),
            actions: [
              IconButton(
                icon: Icon(Icons.calendar_today),
                color:
                    pageIndex == 0 ? companyOrange : defaultTextColor(context),
                onPressed: () => {
                  setState(() => {pageIndex = 0})
                },
              ),
              IconButton(
                icon: Icon(Icons.add),
                color:
                    pageIndex == 1 ? companyOrange : defaultTextColor(context),
                onPressed: () => {
                  setState(() => {
                        pageIndex = 1,
                      })
                },
              ),
              IconButton(
                  icon: Icon(Icons.search),
                  color: pageIndex == 2
                      ? companyOrange
                      : defaultTextColor(context),
                  onPressed: () => {
                        setState(() => {pageIndex = 2})
                      }),
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () => {},
              )
            ],
            bottom: PreferredSize(
                child: Container(
                  color: Colors.black,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(0))),
        body: pages[pageIndex],
        bottomNavigationBar: buildBottomBar());
  }
}
