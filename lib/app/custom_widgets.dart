import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HomePageCounterButton {
  static Widget get(String text, int counter, dynamic color,
      dynamic counterColor, double width, int position) {
    double border1 = position == 1 ? 5 : 0;
    double border2 = position == 3 ? 5 : 0;
    return Column(children: [
      Container(
        child: Text(text,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
        ),
        alignment: Alignment.center,
        height: 40,
        width: width,
      ),
      Container(
          child: Text(counter.toString(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          decoration: BoxDecoration(
            color: counterColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(border1),
                bottomRight: Radius.circular(border2)),
          ),
          alignment: Alignment.center,
          height: 40,
          width: width)
    ]);
  }
}

AppBar backAppBar(BuildContext context, label) {
  return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0.0,
      title: back(context, label),
      bottom: PreferredSize(
          child: Container(
            color: Colors.black,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(0)));
}

Color defaultTextColor(context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;
}

Container back(BuildContext context, String title) {
  return Container(
      width: 100,
      child: TextButton(
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(
            'ㄑ ',
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
          ),
          Container(
              height: 25,
              padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ))
        ]),
        onPressed: () => {Navigator.of(context).pop()},
      ));
}

Container backToSomewhere(BuildContext context, String title, String route) {
  return Container(
      width: 100,
      child: TextButton(
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(
            'ㄑ ',
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
          ),
          Container(
              height: 25,
              padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ))
        ]),
        onPressed: () =>
            {Navigator.of(context).popUntil(ModalRoute.withName(route))},
      ));
}


  Future<LocationData> getLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _locationData = await location.getLocation();
    return _locationData;
  }



///////////////////////
/// Search Bar
/*

  List searchresult = [];
  List _list = [];

  @override
  void initState() {
    super.initState();
    _isSearching = false;
    values();
  }

  void values() {
    _list = [];
    _list.add("Canada");
    _list.add("USA");
    _list.add("France");
    _list.add("Portugal");
    _list.add("Mexico");
    _list.add("Brazil");
    _list.add("Japan");
    _list.add("England");
  }

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
      for (int i = 0; i < _list.length; i++) {
        //////////////////^ ^ ^ ^ ^ ^ ^/////////////
        /////// Search in Json files (from, title, subtitle)
        /////// Search in Json files (from, title, subtitle)
        /////// Search in Json files (from, title, subtitle)
        String data = _list[i];
        if (data.toLowerCase().contains(newQuery.toLowerCase())) {
          searchresult.add(data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: _isSearching ? const BackButton() : null,
            title: _isSearching ? _buildSearchField() : Text('Messages'),
            actions: _buildActions()),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                  child: searchresult.length != 0 ||
                          _searchQueryController.text.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchresult.length,
                          itemBuilder: (BuildContext context, int index) {
                            String listData = searchresult[index];
                            return ListTile(
                              title: Text(listData.toString()),
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _list.length,
                          itemBuilder: (BuildContext context, int index) {
                            String listData = _list[index];
                            return ListTile(
                              title: Text(listData.toString()),
                            );
                          },
                        ))
            ],
          ),
        ));
*/