import 'dart:convert';

import 'package:http/http.dart' as http;

class Http {
  static Future<Map<String, dynamic>> get(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    return getHttpResult(response);
  }

  static Future<Map<String, dynamic>> post(String url, Object body) async {
    final uri = Uri.parse(url);
    final response = await http.post(uri, body: body);
    return getHttpResult(response);
  }

  static Future<Map<String, dynamic>> getWithJWT(String jwtURL, String idToken) async {
    final uri = Uri.parse(jwtURL);
    final response = await http.get(uri, headers: {"x-access-token": idToken});
    return getHttpResult(response);
  }

  static Future<Map<String, dynamic>> postWithJWT(String jwtURL, String idToken, Object body) async {
    final uri = Uri.parse(jwtURL);
    var response = await http.post(uri, headers: {"x-access-token": idToken}, body: body);
    return getHttpResult(response);
  }

  static Future<Map<String, dynamic>> patchWithJWT(String jwtURL, String idToken, Object body) async {
    final uri = Uri.parse(jwtURL);
    var response = await http.patch(uri, headers: {"x-access-token": idToken}, body: body);
    return getHttpResult(response);
  }

  static Future<Map<String, dynamic>> deleteWithJWT(String jwtURL, String idToken) async {
    final uri = Uri.parse(jwtURL);
    var response = await http.delete(uri, headers: {"x-access-token": idToken});
    return getHttpResult(response);
  }

  static Map<String, dynamic> getHttpResult(http.Response response) {
    Map<String, dynamic> result = {};
    if (response.statusCode == 200) {
      result["data"] = utf8.decode(response.bodyBytes);
    } else {
      print(response.statusCode);
      result["error"] = true;
      result["errorCode"] = response.statusCode;
    }
    return result;
  }
}
