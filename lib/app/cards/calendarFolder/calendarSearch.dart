import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../custom_widgets.dart';
import '../../AppTheme.dart';
import 'dart:convert';
import 'dart:async';
import 'calendarMain.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

class CalendarSearch extends StatefulWidget {
  @override
  _CalendarSearchState createState() => _CalendarSearchState();
}

class _CalendarSearchState extends State<CalendarSearch> {
  TextEditingController _searchQueryController = TextEditingController();
  List _jobss = [];
  List searchresult = [];
  bool _isSearching = false;
  String searchQuery = "Search...";
  List nearbyresults = [];
  bool nearby = false;
  bool edit = false;
  DateTime now = DateTime.now();
  int jobStatus = 0;
  bool sort = false;
  LocationData _currentLocation;

  Future<void> readJsonJobsAgain() async {
    final response = await rootBundle.loadString('assets/jobs.json');
    final data = await json.decode(response);
    data["jobs"].forEach((c) => {c["visible"] = true});

    setState(() {
      _jobss = data["jobs"];
      //_jobs.sort((a, b) => a["name"].compareTo(b["name"]));
    });
  }

  TextField buildSearchField() {
    return TextField(
      onTap: _startSearch,
      controller: _searchQueryController,
      decoration: InputDecoration(
          hintText: "Search...",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: companyOrange),
          suffixIcon: FocusScope.of(context).hasFocus && _isSearching == true
              ? IconButton(
                  icon: Icon(Icons.clear),
                  color: companyOrange,
                  onPressed: () => {
                        FocusScope.of(context).unfocus(),
                        _stopSearching(),
                      })
              : null,
          hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white30
                  : Colors.grey[800])),
      style: TextStyle(fontSize: 16.0),
      onChanged: (query) => {updateSearchQuery(query)},
    );
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    for (int i = 0; i < _jobss.length; i++) {
      String nameData = _jobss[i]["jobType"]["name"];
      String clientNameData = _jobss[i]["client"]["name"];
      String cityData = _jobss[i]["address"]["city"];
      String addressData = _jobss[i]["address"]["full"];
      if (newQuery.isEmpty ||
          nameData.toLowerCase().contains(newQuery.toLowerCase()) ||
          clientNameData.toLowerCase().contains(newQuery.toLowerCase()) ||
          cityData.toLowerCase().contains(newQuery.toLowerCase()) ||
          addressData.toLowerCase().contains(newQuery.toLowerCase())) {
        _jobss[i]["visible"] = true;
      } else {
        _jobss[i]["visible"] = false;
      }
    }
    setState(() {
      searchQuery = newQuery;
      _jobss = _jobss;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  void initState() {
    if (_jobss.length == 0) {
      readJsonJobsAgain();
    }
    initAsync();
    _isSearching = false;
    super.initState();
  }

  void initAsync() async {
    _currentLocation = await getLocation();
  }

  void isVisible(jobStatus) {
    DateTime today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < _jobss.length; i++) {
      DateTime start = DateTime.parse(_jobss[i]["start"]);
      DateTime end = DateTime.parse(_jobss[i]["end"]);
      DateTime otherStart = DateTime(start.year, start.month, start.day);
      DateTime otherEnd = DateTime(end.year, end.month, end.day);

// TO BE FINISHED
      // }
      if (jobStatus != 0) {
        if (_jobss[i]["status"] < 5 && otherEnd.isBefore(today)) {
          jobStatus == 2
              ? _jobss[i]["visible"] = true
              : _jobss[i]["visible"] = false;
        } else if (_jobss[i]["status"] == 5) {
          jobStatus == 1
              ? _jobss[i]["visible"] = true
              : _jobss[i]["visible"] = false;
        } else if (_jobss[i]["status"] == 2 &&
            otherStart.isAtSameMomentAs(today)) {
          jobStatus == 1
              ? _jobss[i]["visible"] = true
              : _jobss[i]["visible"] = false;
        } else if (_jobss[i]["status"] == 2 && otherStart.isAfter(today)) {
          jobStatus == 3
              ? _jobss[i]["visible"] = true
              : _jobss[i]["visible"] = false;
        }
      } else {
        _jobss[i]["visible"] = true;
      }
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  buildSortRow(label, condition, [condition2 = ""]) {
    return InkWell(
        onTap: () {
          setState(() => {
                condition2 != ""
                    ? _jobss.sort((a, b) => a[condition][condition2]
                        .compareTo(b[condition][condition2]))
                    : _jobss
                        .sort((a, b) => a[condition].compareTo(b[condition])),
              });
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 35,
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.black),
          )),
          child: Text(label),
        ));
  }

  bool findLocation = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton(
            onPressed: () => {},
            child: Icon(Icons.qr_code_scanner, color: Colors.white),
            style: ElevatedButton.styleFrom(
                primary: companyOrange,
                elevation: 4,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(Radius.circular(5.0))))),
        ElevatedButton(
            onPressed: () => {
                  setState(() => {
                        sort ? sort = false : sort = true,
                        jobStatus = 0,
                        isVisible(jobStatus),
                        if (findLocation == true)
                          {
                            findLocation = false,
                            for (int i = 0; i < _jobss.length; i++)
                              {
                                _jobss[i]["distance"] = calculateDistance(
                                    _currentLocation.latitude,
                                    _currentLocation.longitude,
                                    _jobss[i]["position"]["latitude"],
                                    _jobss[i]["position"]["longitude"])
                              }
                          },
                        _jobss.sort((a, b) => a["start"].compareTo(b["start"]))
                      })
                },
            child: Row(children: [
              Text("Sort ",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white)),
              Icon(Icons.sort),
            ]),
            style: ElevatedButton.styleFrom(
                primary: sort ? Colors.greenAccent[700] : companyOrange,
                elevation: 4,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(Radius.circular(5.0))))),
        Container(
          child: buildSearchField(),
          width: 200,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Colors.grey[100],
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        ),
      ]),
      SizedBox(height: 5),
      Container(height: 0.5, color: Colors.black),
      sort
          ? Column(
              children: [
                buildSortRow('Date', "start"),
                buildSortRow('Customer', "jobType", "name"),
                buildSortRow('Site', "site", "id"),
                buildSortRow('Equipment', "equip", "id"),
                buildSortRow('Nearby', "distance"),
                /*
                buildSortRow('Nearby Job', "jobType", "name"),
                buildSortRow('Town', "site", "id"),
                */
              ],
            )
          : Container(
              height: 30,
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(children: [
                SizedBox(width: 5),
                ElevatedButton(
                    onPressed: () => {
                          setState(() {
                            jobStatus == 1 ? jobStatus = 0 : jobStatus = 1;
                            isVisible(jobStatus);
                          })
                        },
                    child: Text("COMPLETED",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.horizontal(left: Radius.circular(5)),
                        ),
                        primary: jobStatus == 1
                            ? Colors.greenAccent[700]
                            : Colors.grey[800])),
                ElevatedButton(
                    onPressed: () => {
                          setState(() {
                            jobStatus == 2 ? jobStatus = 0 : jobStatus = 2;
                            isVisible(jobStatus);
                          })
                        },
                    child: Text("LATE",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(),
                        primary: jobStatus == 2
                            ? Colors.red[600]
                            : Colors.grey[800])),
                ElevatedButton(
                    onPressed: () => {
                          setState(() {
                            jobStatus == 3 ? jobStatus = 0 : jobStatus = 3;
                            isVisible(jobStatus);
                          })
                        },
                    child: Text("UPCOMING",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(5)),
                        ),
                        primary: jobStatus == 3
                            ? Colors.grey[700]
                            : Colors.grey[800])),
                SizedBox(width: 45),
                ElevatedButton(
                    onPressed: () => {
                          setState(() {
                            jobStatus == 4 ? jobStatus = 0 : jobStatus = 4;
                            isVisible(jobStatus);
                          })
                        },
                    child: Text("ACTIVITIES",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(5),
                              right: Radius.circular(5)),
                        ),
                        primary:
                            jobStatus == 4 ? companyOrange : Colors.grey[800])),
                SizedBox(width: 5)
              ]),
            ),
      sort ? SizedBox() : Container(height: 0.5, color: Colors.black),
      Expanded(
        child: ListView.builder(
            itemCount: _jobss.length,
            itemBuilder: (BuildContext context, int index) {
              return jobCardBuilder(_jobss, index);
            }),
      )
    ]);
  }
}
