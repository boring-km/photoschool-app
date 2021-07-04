import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../dto/school/school_rank.dart';

class SchoolRankMap extends StatefulWidget {

  final List<SchoolRank> schoolList;

  const SchoolRankMap({Key? key, required this.schoolList}) : super(key: key);

  @override
  _SchoolRankMapState createState() => _SchoolRankMapState();
}

class _SchoolRankMapState extends State<SchoolRankMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height:MediaQuery.of(context).size.height,
            child: GoogleMap(initialCameraPosition: CameraPosition(target:LatLng(
                37,
                127),
              zoom:18,
            )
            )
        ),
      )
    );
  }

}
