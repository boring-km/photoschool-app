import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'http_custom.dart';

class GoogleGeoCoding {
  static Future<LatLng> getLatLng(String address) async {
    final fixedAddress = address.replaceAll(' ', '+');
    final apiKey = dotenv.env["google_geocoding_key"];
    var url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$fixedAddress&key=$apiKey';
    final result = await Http.get(url);
    final latlng = jsonDecode(result['data'])['results'][0]['geometry']['location'];
    final latitude = latlng['lat'];
    final longitude = latlng['lng'];
    return LatLng(latitude, longitude);
  }
}