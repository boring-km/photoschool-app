import 'dart:convert';

import 'package:photoschool/utils/http_custom.dart';
import 'package:test/test.dart';

void main() {
  test("geocoding test", () async {
    final address = '서울특별시 종로구 세종로 사직로 161'.replaceAll(' ', '+');
    final apiKey = ''; // dotenv.env["google_geocoding_key"];
    var url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';
    final result = await Http.get(url);
    print(result);
    final json = jsonDecode(result['data']);
    print(json);
  });
}