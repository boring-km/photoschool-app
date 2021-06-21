import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photoschool/domain/detail_request.dart';
import 'package:photoschool/domain/search_request.dart';
import 'package:photoschool/domain/searched_detail_item.dart';
import 'package:photoschool/domain/searched_item.dart';
import 'package:photoschool/utils/http_custom.dart';
import 'package:photoschool/utils/xml_custom.dart';

class PublicAPIService {

  static Future<List<SearchedCreature>> getChildBookSearch(String keyword, int page) async {
    final baseUrl = dotenv.env["public_api_list_url"]!;
    final serviceKey = dotenv.env["public_api_key"]!;
    final numOfRows = 10;
    final target = SearchRequest(baseUrl, serviceKey, 1, keyword, numOfRows, page).toString();
    List<SearchedCreature> creatureList = [];
    var result = await Http.get(target);
    if (result['error'] != null) {
      print(result['errorCode']);
    } else {
      final searched = result['data'];
      final list = XMLParser.parseXMLItems(searched);
      for (var item in list) {
        final apiId = int.parse(item.getChild('childLvbngPilbkNo')!.text!);
        final name = item.getChild('lvbngKrlngNm')!.text!;
        final type = item.getChild('lvbngTpcdNm')!.text!;
        creatureList.add(SearchedCreature(name, type, apiId));
      }
    }
    return creatureList;
  }

  static getChildBookDetail(int apiId) async {
    final baseUrl = dotenv.env["public_api_detail_url"]!;
    final serviceKey = dotenv.env["public_api_key"]!;
    final target = DetailRequest(baseUrl, serviceKey, apiId).toString();
    var result = await Http.get(target);
    if (result['error'] != null) {
      print(result['errorCode']);
      return false;
    } else {
      final searched = result['data'];
      final item = XMLParser.parseXMLItem(searched);
      return SearchedDetailItem(
          item.getChild('lvbngKrlngNm')!.text != null ? item.getChild('lvbngKrlngNm')!.text! : "",
          item.getChild('lvbngTpcdNm')!.text!,
          item.getChild('famlKrlngNm')!.text!,
          item.getChild('hbttNm')!.text != null ? item.getChild('hbttNm')!.text! : "",
          item.getChild('lvbngDscrt')!.text != null ? item.getChild('lvbngDscrt')!.text! : "",
          item.getChild('imgUrl1')!.text!,
          item.getChild('imgUrl2')!.text!,
          item.getChild('imgUrl3')!.text!);
    }
  }


}