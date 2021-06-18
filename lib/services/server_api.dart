import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photoschool/utils/http_custom.dart';

class CustomAPIService {
  static Future<String> checkUserRegistered() async {
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.getWithJWT("$domain/check", idToken);
    return _getResult(result);
  }

  // TODO: 추후에 반환형은 Post 객체가 되어야 함
  static Future<String> getMyPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.getWithJWT("$domain/mypost/$index", idToken);
    return _getResult(result);
  }

  // TODO: 반환형 Post
  static Future<String> getOthersPostBy(int apiId, int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/others/$apiId/$index");
    return _getResult(result);
  }

  static _getResult(Map<String, dynamic> result) {
    if (result['error'] == null) {
      return result['data'];
    } else {
      return '${result['errorCode']}';
    }
  }
}