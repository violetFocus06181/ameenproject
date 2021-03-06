import 'dart:convert';

import 'package:ameen_project/model/jummah_model.dart';
import 'package:ameen_project/screens/add_jummah_page.dart';
import 'package:ameen_project/screens/each_jummah_page.dart';
import 'package:ameen_project/screens/jummah_marker_page.dart';
import 'package:flutter/material.dart';
import 'package:ameen_project/utils/azan_timer_box.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class JummahPage1 extends StatefulWidget {
  _JummahPage1State createState() => _JummahPage1State();
}

class _JummahPage1State extends State<JummahPage1> 
    with SingleTickerProviderStateMixin {
  TabController tabController;
  String _prayer_name = "Fajar";
  JummahModel _jummahModel;
  String _searchHint = "Search cemeteries";
  String _currentLatitude = "23.7283019";
  String _currentLongitude = "90.3984344";
  String _location_name = "";
  String _miles = "";
  bool _azanTimeSwitched = true;

  var _filterJummahList;
  List<Events> _jummahList;

  _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (preferences.containsKey('_azanTimeSwitched')) {
      _azanTimeSwitched = preferences.getBool('_azanTimeSwitched');
      }
      _currentLatitude = preferences.getString("latitude");
      _currentLongitude = preferences.getString("longitude");
      _prayer_name = preferences.getString("prayer_name");
      var parts = _prayer_name.split("^");
      _prayer_name = parts[0] + parts[1];
    });
  }

  _getJummahApiCall({String cityName = "", String miles = "300"}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var jsonData = null;
    final response = await http.get(
        "http://ameenproject.org/appadmin/public/api/v1/jummah"
        "/${_currentLatitude}/${_currentLongitude}/${miles}${cityName}",
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });

    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _jummahModel = new JummahModel.fromJson(jsonData);
        _jummahList = _jummahModel.data.events;
        _filterJummahList = _jummahList;
      });
    }
    print("event request@@@@@@@ ${response.request.toString()}");
    print('Token : ${token}');
    print(jsonData.toString());
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 250,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Filter List',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'You can filter list with city name and miles.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 40.0,
                        child: TextField(
                          onChanged: (value) {
                            _miles = value;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEFEFEF),
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 11, top: 11, right: 15),
                            hintText: '10 miles',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 40.0,
                        child: TextField(
                          onChanged: (value) {
                            _location_name = value;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEFEFEF),
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 11, top: 11, right: 15),
                            hintText: 'New York',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_location_name.isNotEmpty ||
                                  _miles.isNotEmpty)
                                _getJummahApiCall(
                                    cityName: "/${_location_name}",
                                    miles: _miles);
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: Text(
                              'Filter',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var jummahs = List<Events>();
    Data data = Data(events: jummahs);
    _jummahModel = JummahModel(success: true, message: "success", data: data);
    _jummahList = _jummahModel.data.events;
    _filterJummahList = _jummahList;
//    print("places from api: $_filterPlaceList");
    _loadData();
    _getJummahApiCall();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: getAppBar(context, "Jummah", _prayer_name, _azanTimeSwitched)),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
//          Expanded(
//            flex: _flex_value,
//            child:  _azanTimeSwitched ? getAlarm(context, _prayer_name) : Container(),
//          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(bottom: 10.0),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50.0,
                        child: TextField(
                          onChanged: (value) {
                            value = value.toLowerCase();
                            print(value);
                            setState(() {
                              print("places from api: ${_jummahList[0].name}");
                              _filterJummahList = _jummahList
                                  .where((u) => (
//                              print("u.name: ${u.name}")));
                                      u.name
                                          .toLowerCase()
                                          .contains(value.toLowerCase())))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEFEFEF),
                            hintText: _searchHint,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26.0),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      child: new Image.asset('assets/setup.png'),
                      onPressed: () {
                        _displayDialog(context);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      child: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return AddJummahPage();
                            }));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: getListView(this._filterJummahList),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: Icon(
          Icons.location_on,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return JummahMarkerPage(this._jummahModel.data.events);
          }));
        },
      ),
    );
  }
}

String getAppBarTitle(bool position) {
  return position ? 'Cemeteries' : 'Funeral Homes';
}

Widget getListView(List<Events> places) {
//  print("places from api: $places");

  var listView = ListView.builder(
      itemCount: places.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return EachJummahPage(places[index]);
                }));
          },
          child: Container(
            color: index % 2 == 1 ? Color(0xffF5F5F5) : Color(0xffEBEBEB),
            width: MediaQuery.of(context).size.width,
            //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        places.isNotEmpty ? places[index].name : "Place Name",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4.0),
                      child: Text(
                        places.isNotEmpty && places[index].thirdJummah != null  ?
                        "Jummah: " + places[index].firstJummah + " | " + places[index].secondJummah + " | " + places[index].thirdJummah 
                        : "Jummah: " + places[index].firstJummah + " | " + places[index].secondJummah,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        );
      });
  return listView;
}
