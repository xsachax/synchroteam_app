import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../AppTheme.dart';

class Event {}

Container jobCardBuilder(_jobs, index) {
  if (_jobs[index]["visible"]) {
    return Container(
        height: 55,
        child: Card(
            margin: EdgeInsets.all(2.0),
            child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                leading: SizedBox(
                  height: 55,
                  width: 80,
                  child: Row(children: [
                    Container(
                        width: 75,
                        padding: EdgeInsets.fromLTRB(0, 6, 18, 0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(jobTime(_jobs[index]["start"]),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  )),
                              Text(jobTime(_jobs[index]["end"]),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13))
                            ])),
                    Container(
                      width: 5,
                      height: double.infinity,
                      color: jobColor(_jobs, index, _jobs[index]["start"],
                          _jobs[index]["end"]),
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
                    )
                  ]),
                ),
                title: Container(
                    padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_jobs[index]["jobType"]["name"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                              _jobs[index]["client"]["name"] +
                                  ", " +
                                  _jobs[index]["address"]["full"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w300))
                        ])),
                trailing: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: jobIcon(_jobs, index)))));
  } else {
    return Container();
  }
}

jobTime(dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime dt1 = DateTime.parse(dateTime);
  DateTime dt2 = DateTime(dt1.year, dt1.month, dt1.day);

  if (dt2.isAtSameMomentAs(today)) {
    return DateFormat.jm().format(dt1);
  } else {
    return DateFormat.MMMMd().format(dt1).substring(0, 3) +
        " " +
        DateFormat.d().format(dt1);
  }
}

jobColor(_jobs, index, dateTimeStart, dateTimeEnd) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime start = DateTime.parse(dateTimeStart);
  DateTime end = DateTime.parse(dateTimeEnd);
  DateTime otherStart = DateTime(start.year, start.month, start.day);
  DateTime otherEnd = DateTime(end.year, end.month, end.day);

  if (_jobs[index]["status"] == 5) {
    return Colors.blue[700];
  } else if (_jobs[index]["status"] == 2 &&
      otherStart.isAtSameMomentAs(today)) {
    return Colors.greenAccent[400];
  } else if (_jobs[index]["status"] < 5 && otherEnd.isBefore(today)) {
    return Colors.red;
  } else if (_jobs[index]["status"] == 2 && otherStart.isAfter(today)) {
    return Colors.grey[700];
  } else {
    return Colors.orangeAccent[700];
  }
}

jobIcon(_jobs, index) {
  if (_jobs[index]["priority"] == "high") {
    return Icon(Icons.warning_rounded, color: Colors.red);
  } else if (_jobs[index]["priority"] == "low") {
    return Icon(Icons.arrow_downward, color: Colors.blue[600]);
  } else {
    return SizedBox();
  }
}

class CalendarMain extends StatefulWidget {
  @override
  _CalendarMainState createState() => _CalendarMainState();
}

class _CalendarMainState extends State<CalendarMain> {
  List _jobs = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> selectedEvents;
  DateTime time;
  DateTime d;
  DateTime now = DateTime.now();

  Future<void> readJsonJobs() async {
    final today = DateTime(now.year, now.month, now.day);
    final response = await rootBundle.loadString('assets/jobs.json');
    final data = await json.decode(response);
    data["jobs"].forEach((c) => {
          if (DateTime.parse(c["start"]).isAtSameMomentAs(today) ||
              DateTime.parse(c["end"]).isAtSameMomentAs(today))
            {c["visible"] = true}
          else
            {c["visible"] = false}
        });

    setState(() {
      _jobs = data["jobs"];
      //_jobs.sort((a, b) => a["name"].compareTo(b["name"]));
    });
  }

  /* NOTES 
status: 2 = Synchronized
        3 = Started
        4 = Paused
        5 = Completed

status = 5 (bleu)
status = 2 et start = today (vert)
status < 5 et end < today (rouge! (late))
status = 2 et start > today (gris! (upcoming))

*/

  @override
  void initState() {
    if (_jobs.length == 0) {
      readJsonJobs();
    }
    selectedEvents = {};
    super.initState();
  }

  _getEventsForDay(DateTime day) {
    final currentDate = DateTime(day.year, day.month, day.day);

    for (int i = 0; i < _jobs.length; i++) {
      DateTime s = DateTime.parse(_jobs[i]["start"]);
      DateTime startDate = DateTime(s.year, s.month, s.day);
      DateTime e = DateTime.parse(_jobs[i]["end"]);
      DateTime endDate = DateTime(e.year, e.month, e.day);

      if (startDate.isAtSameMomentAs(currentDate) ||
          endDate.isAtSameMomentAs(currentDate)) {
        _jobs[i]["visible"] = true;
      } else {
        _jobs[i]["visible"] = false;
      }
    }

    setState(() {
      _jobs = _jobs;
    });
  }

  Color markerColor(day) {
    Color clr;
    DateTime today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < _jobs.length; i++) {
      DateTime start = DateTime.parse(_jobs[i]["start"]);
      DateTime end = DateTime.parse(_jobs[i]["end"]);
      DateTime otherStart = DateTime(start.year, start.month, start.day);
      DateTime otherEnd = DateTime(end.year, end.month, end.day);

      if (otherStart.isAtSameMomentAs(day)) {
        if (_jobs[i]["status"] < 5 && otherEnd.isBefore(today)) {
          clr = Colors.red;
        } else if (_jobs[i]["status"] == 5) {
          clr = Colors.blue[700];
        } else if (_jobs[i]["status"] == 2 &&
            otherStart.isAtSameMomentAs(today)) {
          clr = Colors.greenAccent[400];
        } else if (_jobs[i]["status"] == 2 && otherStart.isAfter(today)) {
          return Colors.grey[700];
        } else {
          clr = Colors.orangeAccent[700];
        }
      }
    }
    return clr;
  }

  List<Event> _getEvents(day) {
    for (int i = 0; i < _jobs.length; i++) {
      time = DateTime(
          DateTime.parse(_jobs[i]["start"]).year,
          DateTime.parse(_jobs[i]["start"]).month,
          DateTime.parse(_jobs[i]["start"]).day);
      if (selectedEvents[time] != null) {
        selectedEvents[time].add(Event());
      } else {
        selectedEvents[time] = [Event()];
      }
    }

    d = DateTime(day.year, day.month, day.day); // WILL BE USED FOR COLOR

    return selectedEvents[d] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          child: TableCalendar(
              firstDay: DateTime.utc(2018, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _getEventsForDay(_selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _getEvents(day);
              },
              calendarBuilders:
                  CalendarBuilders(singleMarkerBuilder: (context, date, event) {
                Color c =
                    markerColor(DateTime(date.year, date.month, date.day));
                return Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c),
                  width: 7.0,
                  height: 7.0,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                );
              }, dowBuilder: (context, day) {
                final text = DateFormat.E().format(day);

                return Center(
                    child: Text(text, style: TextStyle(color: companyOrange)));
              }),
              /*daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                        color: selectedEvents[d] == null
                            ? Color(4283387727)
                            : markerColor(DateTime(d.year, d.month, d.day))),
                    weekendStyle: TextStyle(color: null)), */
              // CALENDAR STYLE

              calendarStyle: CalendarStyle(
                markersMaxCount: 1,
                todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                todayDecoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    shape: BoxShape.circle),
                selectedTextStyle: TextStyle(fontSize: 17.0),
                selectedDecoration:
                    BoxDecoration(color: companyOrange, shape: BoxShape.circle),
                //outsideTextStyle: TextStyle(color: dateColor(_selectedDay))
              ),
              headerStyle: HeaderStyle(
                  titleCentered: true, formatButtonVisible: false))),
      Container(height: 6, color: companyOrange),
      Expanded(
          child: ListView.builder(
              itemCount: _jobs.length,
              itemBuilder: (BuildContext context, int index) {
                return jobCardBuilder(_jobs, index);
              })),
      /*..._getEvents(_selectedDay)
              .map(
            (Event event) => Container(
                width: 200, color: Colors.red, child: Text(event.title)))*/
    ]);
  }
}
