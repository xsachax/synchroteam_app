import 'package:flutter/material.dart';
import '../custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:flutter_basic/app/custom_widgets.dart';
import 'dart:convert';
import 'dart:async';
import '../AppTheme.dart';
//import 'dart:developer' as developer;

class Customers extends StatefulWidget {
  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  List _customers = [];
  TextEditingController _searchQueryController = TextEditingController();
  List searchresult = [];
  bool _isSearching = false;
  String searchQuery = "Search...";
  List nearbyresults = [];
  bool nearby = false;
  LocationData _currentLocation;
  bool edit = false;

  Future<void> readJsonCustomers() async {
    final response = await rootBundle.loadString('assets/customers.json');
    final data = await json.decode(response);
    data["customers"].forEach((c) => c["visible"] = true);

    setState(() {
      _customers = data["customers"];
      _customers.sort((a, b) => a["name"].compareTo(b["name"]));
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
    for (int i = 0; i < _customers.length; i++) {
      String nameData = _customers[i]["name"];
      String cityData = _customers[i]["address"]["city"];
      String provinceData = _customers[i]["address"]["province"];
      if (newQuery.isEmpty ||
          nameData.toLowerCase().contains(newQuery.toLowerCase()) ||
          cityData.toLowerCase().contains(newQuery.toLowerCase()) ||
          provinceData.toLowerCase().contains(newQuery.toLowerCase())) {
        _customers[i]["visible"] = true;
      } else {
        _customers[i]["visible"] = false;
      }
    }
    setState(() {
      searchQuery = newQuery;
      _customers = _customers;
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
    if (_customers.length == 0) {
      readJsonCustomers();
    }
    _isSearching = false;
    initAsync();
    super.initState();
  }

  void initAsync() async {
    _currentLocation = await getLocation();
  }

  buildFormRow(leadingWidget, trailingWidget) {
    return Container(
      child: Row(
        children: [leadingWidget, trailingWidget],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5),
        ),
        shape: BoxShape.rectangle,
      ),
      height: 45,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    );
  }

  buildExpandableRowForm(String label, items, index) {
    return Container(
        child: InkWell(
            onTap: () => {
                  items.isNotEmpty ? expandableFieldPressed(items, index) : null
                },
            child: Row(
              children: [
                Container(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            color: items.length > 0
                                ? companyOrange
                                : Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.left)),
                Row(
                  children: [
                    Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                        padding: EdgeInsets.fromLTRB(0, 5.5, 0, 0),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: items.length > 0
                                ? companyOrange
                                : Colors.grey[800],
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(items.length.toString(),
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.center)),
                    Container(
                        child: items.length > 0
                            ? Icon(Icons.chevron_right, color: companyOrange)
                            : Container(width: 23.5))
                  ],
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
            )),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5),
          ),
          shape: BoxShape.rectangle,
        ),
        height: 45,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0));
  }

  listTileBuilder(title, subtitle) {
    return Container(
        child: ListTile(
            title: Text(title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: companyOrange,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.left),
            subtitle: Text(subtitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 19,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    fontWeight: FontWeight.w300),
                textAlign: TextAlign.left)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5),
          ),
          shape: BoxShape.rectangle,
        ),
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0));
  }

  expandableFieldPressed(items, index) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: backAppBar(context, 'Back'),
          body: Column(children: [
            separation(),
            buildFormRow(
                leadingText(_customers[index]["name"], _textColorGenerator(),
                    19.0, FontWeight.w600, 350.0),
                trailingText('')),
            Expanded(
                child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int indx) {
                      return listTileBuilder(
                          items[indx]['label'], items[indx]['value']);
                    }))
          ]));
    }));
  }

  final formKey = GlobalKey<FormState>();
  final editKey = GlobalKey<FormState>();

  String returnMessage;

  formField(label, icon, index, email, phone) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: TextFormField(
          //
          // Lib Phone Number
          //
          cursorColor: companyOrange,
          keyboardType: phone ? TextInputType.phone : TextInputType.text,
          autocorrect: false,
          inputFormatters: [
            phone
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.singleLineFormatter
          ],
          decoration: InputDecoration(
            icon: Icon(icon, color: companyOrange),
            labelText: label,
            focusColor: companyOrange,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: companyOrange)),
          ),
          validator: (input) {
            if (input == null || input.isEmpty) {
              return 'Please enter some text';
            } else if (email) {
              if (!input.contains('@')) {
                return 'Invalid email';
              }
            }

            return null;
          },
          onSaved: (input) => {
            setState(() => {variables[index] = input})
          },
        ));
  }

/*
  inputField(
      label, size, weight, alignment, controller, storedLocation, query) {
    return Container(
      child: TextField(
          textAlign: alignment,
          onTap: () => {
                ModalRoute.of(context).addLocalHistoryEntry(
                    LocalHistoryEntry(onRemove: () => {controller.clear()}))
              },
          controller: controller,
          decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
              hintStyle: TextStyle(
                  fontSize: size,
                  fontWeight: weight,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white30
                      : Colors.grey[800])),
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
          ),
          onSubmitted: (query) => {
                setState(() => {storedLocation = query}),
              }),
      width: 200,
      height: 40,
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : Colors.grey[100],
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
    );
  }
  */

  formField2(width, alignment, previousValue, extraValue, index, email, phone,
      [rightPad = 0.0]) {
    return Container(
        height: 45,
        padding: EdgeInsets.fromLTRB(10, 0, rightPad, 0),
        width: width,
        child: TextFormField(
          textAlign: alignment,
          keyboardType: phone ? TextInputType.phone : TextInputType.text,
          autocorrect: false,
          inputFormatters: [
            phone
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.singleLineFormatter
          ],
          decoration: InputDecoration(
              hintText: previousValue == "" || previousValue == null
                  ? extraValue
                  : previousValue,
              errorStyle: TextStyle(height: 0)),
          validator: (input) {
            if (email) {
              if (input.isNotEmpty && !input.contains('@')) {
                return '';
              }
            }

            return null;
          },
          onSaved: (input) => {
            setState(() => {
                  input == null || input.isEmpty
                      ? newValues[index] = previousValue
                      : newValues[index] = input
                })
          },
        ));
  }

  leadingText(label, color, size, weight, width) {
    return Container(
        width: width,
        child: Text(label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: color, fontSize: size, fontWeight: weight),
            textAlign: TextAlign.left));
  }

  Text trailingText(text) {
    return Text(text,
        style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[900],
            fontWeight: FontWeight.w300),
        textAlign: TextAlign.right);
  }

  List<String> variables = ['', '', '', '', '', '', ''];
  List<String> newValues = ['', '', '', '', '', '', ''];
  List nameSplit;

  void validateNewCustomer() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      _customers.add({
        "name": variables[0],
        "address": {
          "full": variables[1],
          "complement": variables[2],
        },
        "contact": {
          "email": variables[6],
          "firstName": variables[3].split(" ")[0],
          "lastName":
              variables[3].contains(" ") ? variables[3].split(" ")[1] : "",
          "mobile": variables[4],
          "phone": variables[5]
        },
        "customFields": [],
        "jobs": [],
        "sites": [],
        "equipment": [],
        "position": {},
        "tags": [],
        "distance": 0.0,
        "visible": true,
      });
      Navigator.of(context).pop();
    }
  }

  List firstLastName;

  validateEditCustomer(index) {
    if (editKey.currentState.validate()) {
      editKey.currentState.save();
      setState(() => {
            _customers[index]["name"] = newValues[0],
            _customers[index]["address"]["full"] = newValues[1],
            _customers[index]["address"]["complement"] = newValues[2],
            _customers[index]["contact"]["firstName"] =
                newValues[3].split(" ")[0],
            _customers[index]["contact"]["lastName"] =
                newValues[3].split(" ")[1],
            _customers[index]["contact"]["mobile"] = newValues[4],
            _customers[index]["contact"]["phone"] = newValues[5],
            _customers[index]["contact"]["email"] = newValues[6],
          });

      Navigator.of(context).popUntil(ModalRoute.withName('/customers'));
    }
  }

  addCustomer() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: backAppBar(context, 'Back'),
          body: SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Column(children: [
                    formField('Customer Name', Icons.person, 0, false, false),
                    formField('Address', Icons.location_on, 1, false, false),
                    formField('Additional Address', Icons.location_on_outlined,
                        2, false, false),
                    Container(height: 30),
                    formField('Name', Icons.person_outlined, 3, false, false),
                    formField('Mobile Number', Icons.phone, 4, false, true),
                    formField('Phone Number', Icons.phone, 5, false, true),
                    formField('Email', Icons.email, 6, true, false),
                    Container(height: 20),
                  ]))),
          bottomNavigationBar: buildBottomBar(
              Icons.check_circle_outlined,
              25.0,
              'Create',
              Icons.cancel_outlined,
              25.0,
              'Cancel',
              10.0,
              Colors.red,
              130.0,
              validateNewCustomer,
              Navigator.of(context).pop));
    }));
  }

  String getFormattedPhone(String _phoneNumber) {
    if (_phoneNumber.length == 12 && _phoneNumber[0] == "+") {
      return _phoneNumber.substring(0, 2) +
          " (" +
          _phoneNumber.substring(2, 5) +
          ") " +
          _phoneNumber.substring(5, 8) +
          "-" +
          _phoneNumber.substring(8, _phoneNumber.length);
    }

    return _phoneNumber;
  }

  Container separation() {
    return Container(
      height: 10,
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[400],
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.black))),
    );
  }

  Color _textColorGenerator() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  BottomAppBar buildBottomBar(
      firstIcon,
      firstIconSize,
      firstLabel,
      secondIcon,
      secondIconSize,
      secondLabel,
      secondSpacing,
      secondColor,
      buttonWidth,
      firstFunction,
      secondFunction) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.all(10),
              width: buttonWidth,
              height: 45,
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: InkWell(
                  onTap: () => {firstFunction()},
                  child: Row(
                    children: [
                      Icon(firstIcon, color: Colors.white, size: firstIconSize),
                      Container(width: 10),
                      Text(firstLabel,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500))
                    ],
                  )),
              decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: BorderRadius.circular(5))),
          Container(
              margin: EdgeInsets.all(10),
              width: buttonWidth,
              height: 45,
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: InkWell(
                  onTap: () => {secondFunction()},
                  child: Row(
                    children: [
                      Icon(secondIcon,
                          color: Colors.white, size: secondIconSize),
                      Container(width: secondSpacing),
                      Text(secondLabel,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500))
                    ],
                  )),
              decoration: BoxDecoration(
                  color: secondColor, borderRadius: BorderRadius.circular(5)))
        ],
      ),
    );
  }

  customerBody(index, edit) {
    return Column(children: [
      separation(),
      edit
          ? formField2(double.infinity, TextAlign.start,
              _customers[index]["name"], 'Customer Name', 0, false, false, 10.0)
          : buildFormRow(
              leadingText(_customers[index]["name"], _textColorGenerator(),
                  19.0, FontWeight.w600, 250.0),
              trailingText('')),
      edit
          ? formField2(
              double.infinity,
              TextAlign.start,
              _customers[index]["address"]["full"],
              'Address',
              1,
              false,
              false,
              10.0)
          : buildFormRow(
              leadingText(_customers[index]["address"]["full"],
                  _textColorGenerator(), 18.0, FontWeight.w300, 340.0),
              IconButton(
                icon: Icon(Icons.location_on),
                color: _customers[index]["position"].isEmpty
                    ? Colors.grey[700]
                    : companyOrange,
                iconSize: 30,
                onPressed: () => {
                  _customers[index]["position"].isEmpty
                      ? null
                      : Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                          return Scaffold(
                              appBar: backAppBar(context, 'Back'),
                              body: Column(
                                children: [
                                  separation(),
                                  buildFormRow(
                                      leadingText(
                                          _customers[index]["name"],
                                          _textColorGenerator(),
                                          19.0,
                                          FontWeight.w600,
                                          350.0),
                                      trailingText('')),
                                  listTileBuilder(
                                      'Latitude',
                                      _customers[index]["position"]["latitude"]
                                          .toString()),
                                  listTileBuilder(
                                      'Longitude',
                                      _customers[index]["position"]["longitude"]
                                          .toString())
                                ],
                              ));
                        }))
                },
              )),
      edit
          ? formField2(
              double.infinity,
              TextAlign.start,
              _customers[index]['address']['complement'],
              'Additional Address',
              2,
              false,
              false,
              10.0)
          : buildFormRow(
              leadingText(
                _customers[index]["address"]["complement"] == ""
                    ? 'Additional Address'
                    : _customers[index]["address"]["complement"],
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]
                    : Colors.grey[800],
                18.0,
                FontWeight.w400,
                350.0,
              ),
              trailingText('')),
      separation(),
      buildFormRow(
          leadingText('Contact', companyOrange, 18.0, FontWeight.w400, 100.0),
          edit
              ? formField2(
                  250.0,
                  TextAlign.end,
                  _customers[index]["contact"]["firstName"] +
                      " " +
                      _customers[index]["contact"]["lastName"],
                  'Name',
                  3,
                  false,
                  false)
              : trailingText(_customers[index]["contact"]["firstName"] +
                  " " +
                  _customers[index]["contact"]["lastName"])),
      buildFormRow(
          leadingText('Mobile', companyOrange, 18.0, FontWeight.w400, 100.0),
          edit
              ? formField2(
                  250.0,
                  TextAlign.end,
                  _customers[index]["contact"]["mobile"],
                  'Mobile Number',
                  4,
                  false,
                  true)
              : trailingText(_customers[index]["contact"]["mobile"] == null
                  ? 'Mobile Number'
                  : getFormattedPhone(
                      _customers[index]["contact"]["mobile"].toString()))),
      buildFormRow(
          leadingText('Phone', companyOrange, 18.0, FontWeight.w400, 100.0),
          edit
              ? formField2(
                  250.0,
                  TextAlign.end,
                  _customers[index]["contact"]["phone"],
                  'Phone Number',
                  5,
                  false,
                  true)
              : trailingText(_customers[index]["contact"]["phone"] == null
                  ? 'Phone Number'
                  : getFormattedPhone(
                      _customers[index]["contact"]["phone"].toString()))),
      buildFormRow(
          leadingText('Email', companyOrange, 18.0, FontWeight.w400, 100.0),
          edit
              ? formField2(
                  250.0,
                  TextAlign.end,
                  _customers[index]["contact"]["email"],
                  'Email',
                  6,
                  true,
                  false)
              : trailingText(_customers[index]["contact"]["email"])),
      buildExpandableRowForm(
          "Additional Information", _customers[index]["customFields"], index),
      separation(),
      buildExpandableRowForm("Jobs", _customers[index]["jobs"], index),
      buildExpandableRowForm("Sites", _customers[index]["sites"], index),
      buildExpandableRowForm(
          "Equipment", _customers[index]["equipment"], index),
      separation(),
      Container(
          alignment: Alignment.topLeft,
          height: 100,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Attachements',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w300)),
            ],
          )),
      separation()
    ]);
  }

  displayCustomer(index, [edit = false]) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: "/displayCustomer"),
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0.0,
                  title: back(context, edit ? 'Cancel' : 'Back'),
                  actions: [
                    edit
                        ? Container()
                        : IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: () => {
                                  setState(() => {edit = true}),
                                  displayCustomer(index, edit)
                                },
                            color: _textColorGenerator()),
                  ],
                  bottom: PreferredSize(
                      child: Container(
                        color: Colors.black,
                        height: 1.0,
                      ),
                      preferredSize: Size.fromHeight(0))),
              body: SingleChildScrollView(
                  child: edit
                      ? Form(key: editKey, child: customerBody(index, edit))
                      : customerBody(index, edit)),
              bottomNavigationBar: edit
                  ? buildBottomBar(
                      Icons.save,
                      30.0,
                      'Save',
                      Icons.cancel,
                      30.0,
                      'Cancel',
                      8.0,
                      Colors.red,
                      120.0,
                      () => {validateEditCustomer(index)},
                      () => {Navigator.of(context).pop()})
                  : buildBottomBar(
                      Icons.build,
                      25.0,
                      'Start Job',
                      Icons.add,
                      30.0,
                      'Create Job',
                      4.0,
                      Colors.blue[600],
                      150.0,
                      () => {},
                      () => {}));
        }));
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
                icon: Icon(Icons.add),
                onPressed: () => {addCustomer()},
              ),
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
        body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                    automaticallyImplyLeading: false,
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () => {
                                    setState(() {
                                      if (_currentLocation != null) {
                                        for (int i = 0;
                                            i < _customers.length;
                                            i++) {
                                          _customers[i]
                                              ["distance"] = calculateDistance(
                                                  _currentLocation.latitude,
                                                  _currentLocation.longitude,
                                                  _customers[i]["position"]
                                                      ["latitude"],
                                                  _customers[i]["position"]
                                                      ["longitude"])
                                              .toStringAsFixed(2);
                                        }
                                      }

                                      if (nearby == false) {
                                        nearby = true;
                                        _customers.sort((a, b) => a["distance"]
                                            .compareTo(b["distance"]));
                                      } else {
                                        nearby = false;
                                        _customers.sort((a, b) =>
                                            a["name"].compareTo(b["name"]));
                                      }
                                    }),
                                  },
                              child: Row(children: [
                                Text("Nearby  ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white)),
                                Icon(Icons.format_list_numbered_rtl)
                              ]),
                              style: ElevatedButton.styleFrom(
                                  primary: nearby
                                      ? Colors.greenAccent[700]
                                      : companyOrange,
                                  elevation: 4,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(5.0))))),
                          Container(
                            child: buildSearchField(),
                            width: 260,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.transparent
                                    : Colors.grey[100],
                                border: Border.all(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          ),
                        ]),
                    pinned: false,
                    floating: true,
                    snap: true,
                    elevation: 4.0,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.grey[400],
                    bottom: PreferredSize(
                        child: Container(
                          color: Colors.black,
                          height: 0.5,
                        ),
                        preferredSize: Size.fromHeight(0))),
              ];
            },
            body: buildListView(_customers, nearby)));
  }

  ListView buildListView(List group, nearby) {
    if (group == null || group.length == 0) {
      return new ListView(children: [new Container()]);
    }
    return new ListView.builder(
        itemCount: group.length,
        itemBuilder: (BuildContext context, int index) {
          if (!group[index]["visible"]) {
            return Container();
          }
          return Card(
              margin: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
              child: new InkWell(
                  onTap: () => {displayCustomer(index)},
                  child: ListTile(
                      title: Text(
                          group[index]["name"] == null
                              ? ''
                              : group[index]["name"],
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                      trailing: Container(
                          alignment: Alignment.centerRight,
                          child: Column(children: [
                            Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    group[index]["address"]["city"] == null
                                        ? ''
                                        : group[index]["address"]["city"],
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                            Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    nearby
                                        ? group[index]["distance"].toString() +
                                            ' km'
                                        : group[index]["address"]["province"] ==
                                                null
                                            ? ''
                                            : group[index]["address"]
                                                ["province"],
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis))
                          ]),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          width: 80,
                          margin: EdgeInsets.fromLTRB(0, 11, 0, 0)))));
        });
  }
}
