import 'package:google_maps_flutter/google_maps_flutter.dart';

class School {
  final String region;
  final String schoolName;
  final LatLng? latLng;

  School(this.region, this.schoolName, this.latLng);

  @override
  String toString() {
    return 'School{region: $region, schoolName: $schoolName, latLng: $latLng}';
  }
}