import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_basic/app/custom_widgets.dart';
import 'dart:convert';
import 'dart:async';
import '../AppTheme.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List _items = [];
  DateTime messageTime;

  List searchresult = [];
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search Messages...";

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Messages...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
      IconButton(
          icon: const Icon(Icons.sync),
          onPressed: () {
            readJson();
          })
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    searchresult.clear();
    if (_isSearching != null) {
      for (int i = 0; i < _items.length; i++) {
        String fromData = _items[i]['from'];
        String titleData = _items[i]['title'];
        String contentData = _items[i]['content'];
        if (fromData.toLowerCase().contains(newQuery.toLowerCase()) ||
            titleData.toLowerCase().contains(newQuery.toLowerCase()) ||
            contentData.toLowerCase().contains(newQuery.toLowerCase())) {
          searchresult.add(_items[i]);
        }
      }
    }
    setState(() {
      searchQuery = newQuery;
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

  messageDate(dateTime) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final today = DateTime(now.year, now.month, now.day);
    DateTime dt1 = DateTime.parse(dateTime);
    DateTime dt2 = DateTime(dt1.year, dt1.month, dt1.day);
    if (dt2.isAtSameMomentAs(today)) {
      return DateFormat.jm().format(dt1);
    } else if (dt2.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else if (dt2.isBefore(yesterday)) {
      return DateFormat.MMMMd().format(dt1);
    } else {
      return DateFormat.yMd().format(dt1);
    }
  }


  void initState() {
    if (_items.length == 0) {
      readJson();
    }
    _isSearching = false;
    super.initState();
  }

  messages(group, index) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0.0,
            title: backToSomewhere(context, 'Back', '/messages'),
            actions: [
              IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  onPressed: () => {
                        if (index - 1 >= 0)
                          {
                            setState(() => {group[index - 1]["read"] = true}),
                            messages(group, index - 1)
                          }
                      }),
              IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  onPressed: () => {
                        if (index + 1 < group.length)
                          {
                            setState(() => {group[index + 1]["read"] = true}),
                            messages(group, index + 1)
                          }
                      }),
              IconButton(
                  icon: Icon(Icons.sync),
                  onPressed: () => {
                        setState(() => {readJson()})
                      }
                  )
            ]),
        body: Column(
          children: [
            Container(
                child: Row(
                  children: [
                    Text(group[index]["from"],
                        style: TextStyle(
                            color: companyOrange,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.left),
                    Text(messageDate(group[index]["date"]),
                        style: TextStyle(
                            color: Colors.greenAccent[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.right)
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.5),
                  ),
                  shape: BoxShape.rectangle,
                ),
                height: 50,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
            Container(
                child: Text(group[index]["title"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left),
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10)),
            Container(
                child: Text(group[index]["content"],
                    style: TextStyle(fontSize: 15), textAlign: TextAlign.start),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 10)),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }));
  }

  Future<void> readJson() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final data = await json.decode(response);
    _items = data["items"];

    setState(() {
      _items = data["items"];
    });
  }

  bool all = true;

  Color _allButtonColor;
  _allButtonColorGenerator() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == Brightness.dark
        ? _allButtonColor = Colors.transparent
        : _allButtonColor = Colors.grey[200];
    return _allButtonColor;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0.0,
            leading: _isSearching ? BackButton() : null,
            title: _isSearching
                ? _buildSearchField()
                : backToSomewhere(context, 'Home', '/main'),
            actions: _buildActions(),
            bottom: PreferredSize(
                child: Container(
                  color: Colors.black,
                  height: 0.5,
                ),
                preferredSize: Size.fromHeight(0))),
        body: Column(children: [
          Container(
              width: double.infinity,
              height: 40,
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () => {
                            setState(() {
                              if (!all) all = true;
                            })
                          },
                      child: Text("ALL",
                          style: TextStyle(
                              color: all ? Colors.white : companyOrange)),
                      style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(5)),
                            side: BorderSide(color: companyOrange),
                          ),
                          primary: all
                              ? companyOrange
                              : _allButtonColorGenerator())),
                  ElevatedButton(
                      onPressed: () => {
                            setState(() {
                              if (all) all = false;
                            })
                          },
                      child: Text("UNREAD",
                          style: TextStyle(
                              color: !all ? Colors.white : companyOrange)),
                      style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(5)),
                            side: BorderSide(color: companyOrange),
                          ),
                          primary: !all
                              ? companyOrange
                              : _allButtonColorGenerator())),
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              )),
          _items.length > 0
              ? Expanded(
                  child: searchresult.length != 0 ||
                          _searchQueryController.text.isNotEmpty
                      ? buildListView(searchresult)
                      : buildListView(_items))
              : Container()
        ]));
  }

  ListView buildListView(List group) {
    return new ListView.builder(
        itemCount: group.length,
        itemBuilder: (BuildContext context, int index) {
          if ((all || !group[index]["read"])) {
            return Card(
                margin: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                child: new InkWell(
                    onTap: () => {
                          setState(() => {group[index]["read"] = true}),
                          messages(group, index),
                        },
                    child: Slidable(
                        actionPane: SlidableScrollActionPane(),
                        actionExtentRatio: 1 / 4,
                        key: ValueKey(index),
                        controller: SlidableController(),
                        direction: Axis.horizontal,
                        secondaryActions: <Widget>[
                          IconSlideAction(
                              caption: group[index]["read"]
                                  ? 'Mark as unread'
                                  : 'Mark as read',
                              color: Colors.blue[700],
                              icon: group[index]["read"]
                                  ? Icons.remove_circle_outlined
                                  : Icons.check_circle_outline,
                              onTap: () => {
                                    setState(() => {
                                          group[index]["read"]
                                              ? group[index]["read"] = false
                                              : group[index]["read"] = true
                                        })
                                  }),
                          IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () => {
                                    setState(() => {_items.removeAt(index)})
                                  })
                        ],
                        child: ListTile(
                            leading: Container(
                              child: Icon(
                                group[index]["read"]
                                    ? null
                                    : Icons.fiber_manual_record,
                                color: companyOrange,
                                size: 20,
                              ),
                              padding: EdgeInsets.fromLTRB(5, 0, 0, 30),
                              width: 5,
                            ),
                            title: Column(children: [
                              Text(group[index]["from"],
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: companyOrange,
                                      fontWeight: FontWeight.w800)),
                              Text(group[index]["title"],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800))
                            ], crossAxisAlignment: CrossAxisAlignment.start),
                            subtitle: Container(
                                child: Text(
                              group[index]["content"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                            trailing: Container(
                                child: Text(messageDate(group[index]["date"]),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: Colors.greenAccent[400],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800)),
                                padding: EdgeInsets.fromLTRB(1, 1, 1, 25),
                                margin: EdgeInsets.fromLTRB(1, 1, 1, 10))))));
          } else {
            return Container();
          }
        });
  }
}
