import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../dto/school/school.dart';
import '../dto/school/school_rank.dart';
import '../res/colors.dart';
import '../services/server_api.dart';
import '../utils/geocode.dart';

class SchoolRankMap extends StatefulWidget {

  final List<SchoolRank> schoolList;

  const SchoolRankMap({Key? key, required this.schoolList}) : super(key: key);

  @override
  _SchoolRankMapState createState() => _SchoolRankMapState();
}

class _SchoolRankMapState extends State<SchoolRankMap> {

  final List<Marker> _markers = [];

  int _selectedRank = 0;
  SchoolRank? _selectedSchool;
  late List<SchoolRank> schoolList = <SchoolRank>[];
  final _latLngList = [];
  final Completer<GoogleMapController> _controller = Completer();
  var _selectedIndex = 0;
  School? _school;
  bool _isLoaded = false;

  var _isHidden = false;

  @override
  void initState() {
    schoolList = widget.schoolList;
    print(schoolList);
    Future.delayed(Duration.zero, () async {
      _school = await CustomAPIService.getMySchool();
      await _setInitialMarkers(schoolList);

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return !_isLoaded ?
    Scaffold(
      backgroundColor: CustomColors.creatureGreen,
      body: Center(
        child: Container(
          child: Text(
            "로딩중",
            style: TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(
                      blurRadius: 4.0,
                      color: Colors.black45,
                      offset: Offset(3.0, 3.0))
                ],
                fontSize: 40),
          ),
        ),
      ),
    ) :
    Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
                width: w,
                height: h,
                child: GoogleMap(
                  mapType: MapType.normal,
                  markers: Set.from(_markers),
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(target: _school!.latLng, zoom:11),
                  onMapCreated: _controller.complete,
                )
            ),
            _selectedSchool != null ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: 90.0),
                child: Container(
                  width: 200,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xC9FFFFFF),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$_selectedRank등 ${_selectedSchool!.schoolName}", style: TextStyle(fontSize: 20),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(
                                CupertinoIcons.eye,
                                color: Colors.black,
                              ),
                            ),
                            Text("조회수: ${_selectedSchool!.sumOfViews}", style: TextStyle(fontSize: 18),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(
                                CupertinoIcons.doc,
                                color: Colors.black,
                              ),
                            ),
                            Text("게시물 수: ${_selectedSchool!.sumOfPosts}", style: TextStyle(fontSize: 18),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ) : Container(),
            _buildFloatingSchoolRank()
          ],
        )
      )
    );
  }

  Positioned _buildFloatingSchoolRank() {
    return Positioned(
              bottom: 50,
              left: 50,
              child: Container(
                width: 200,
                height: _isHidden ? 80 : 250,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  border: Border.all(color: Colors.red, width: 2.0)
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.red,
                            size: 30,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 8),
                            child: Text(
                              "학교 랭킹",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    ),
                    _isHidden ? Container() :
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: schoolList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _selectedIndex = index;
                                      _selectedRank = index+1;
                                      _selectedSchool = schoolList[index];
                                    });
                                    final controller = await _controller.future;
                                    setState(() {
                                      controller.animateCamera(CameraUpdate.newCameraPosition(
                                          CameraPosition(target: _latLngList[index], zoom: 11)
                                      ));
                                    });
                                  },
                                  child: _selectedIndex != index ? Container(
                                    color: Color(0xFFF1F1F1),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text("${index+1}등: ${schoolList[index].schoolName}", style: TextStyle(color: Colors.black, fontSize: 16),),
                                    ),
                                  ) : Container(
                                    color: Color(0xFFFF3A3A),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text("${index+1}등: ${schoolList[index].schoolName}", style: TextStyle(color: Colors.white, fontSize: 16),),
                                    ),
                                  )
                              );
                            },
                          )
                      )
                    ),
                    Container(
                      height: 25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red
                        ),
                        onPressed: () {
                          setState(() {
                            _isHidden = !_isHidden;
                          });
                        },
                        child: _isHidden ? Text("펼치기", style: TextStyle(fontSize: 18),) : Text("가리기", style: TextStyle(fontSize: 18),)
                      ),
                    )
                  ],
                )
              )
          );
  }

  _setInitialMarkers(List<SchoolRank> schoolList) async {
    _latLngList.clear();
    for (var i = 0; i < schoolList.length; i++) {
      var latLng = await GoogleGeoCoding.getLatLng(schoolList[i].address);
      _latLngList.add(latLng);
      _markers.add(
        Marker(
          markerId: MarkerId("$i"),
          draggable: true,
          onTap: () => _showInfo(i+1, schoolList[i]),
          position: latLng
        )
      );

      if (schoolList[i].schoolName == _school!.schoolName) {
        _selectedRank = i+1;
        _selectedSchool = schoolList[i];
        _selectedIndex = i;
      }
    }
    setState(() {
      _isLoaded = true;
    });
  }

  _showInfo(int rank, SchoolRank school) {
    setState(() {
      _selectedRank = rank;
      _selectedSchool = school;
    });
  }

}
