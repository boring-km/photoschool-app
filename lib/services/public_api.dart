import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photoschool/domain/detail_request.dart';
import 'package:photoschool/domain/search_request.dart';
import 'package:photoschool/utils/http_custom.dart';

class PublicAPIService {

  static Future<String> getChildBookSearch(String keyword, int numOfRows, int page) async {
    final baseUrl = dotenv.env["public_api_list_url"]!;
    final serviceKey = dotenv.env["public_api_key"]!;
    final target = SearchRequest(baseUrl, serviceKey, 1, keyword, numOfRows, page).toString();

    var result = await Http.get(target);
    if (result['error'] != null) {
      return result['errorCode'];
    } else {
      return result['data'];
    }
  }

  static Future<String> getChildBookDetail(int apiId) async {
    final baseUrl = dotenv.env["public_api_detail_url"]!;
    final serviceKey = dotenv.env["public_api_key"]!;
    final target = DetailRequest(baseUrl, serviceKey, apiId).toString();
    var result = await Http.get(target);
    if (result['error']) {
      return result['errorCode'];
    } else {
      return result['data'];
    }
  }


}