import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../dto/creature/creature_detail_request.dart';
import '../dto/creature/creature_detail_response.dart';
import '../dto/creature/creature_request.dart';
import '../dto/creature/creature_response.dart';
import '../utils/http_custom.dart';
import '../utils/xml_custom.dart';

class PublicAPIService {

  static Future<List<CreatureResponse>> getChildBookSearch(String keyword, int page) async {
    String? baseUrl = dotenv.env["public_api_list_url"]!;
    if (kIsWeb) {
      baseUrl = dotenv.env["server_domain"];
    }
    final serviceKey = dotenv.env["public_api_key"]!;
    final numOfRows = 9;
    final target = CreatureRequest("$baseUrl/creature", serviceKey, 1, keyword, numOfRows, page).toString();
    var creatureList = <CreatureResponse>[];
    var result = await Http.get(target);
    if (result['error'] != null) {
      print(result['errorCode']);
    } else {
      final searched = result['data'];
      if (kIsWeb) {
        final list = (jsonDecode(searched)['response'])['body']['items']['item'];
        for (var item in list) {
          final apiId = item['childLvbngPilbkNo'];
          final name = item['lvbngKrlngNm'];
          final type = item['lvbngTpcdNm'];
          creatureList.add(CreatureResponse(name, type, "$apiId"));
        }
      } else {
        print("other");
        final list = XMLParser.parseXMLItems(searched);
        var creatureList = <CreatureResponse>[];
        for (var item in list) {
          final apiId = int.parse(item.getChild('childLvbngPilbkNo')!.text!);
          final name = item.getChild('lvbngKrlngNm')!.text!;
          final type = item.getChild('lvbngTpcdNm')!.text!;
          creatureList.add(CreatureResponse(name, type, "$apiId"));
        }
      }
    }
    return creatureList;
  }

  static Future<dynamic> getChildBookDetail(String apiId, String keyword) async {
    String? baseUrl = dotenv.env["public_api_list_url"]!;
    if (kIsWeb) {
      baseUrl = dotenv.env["server_domain"];
    }
    final serviceKey = dotenv.env["public_api_key"]!;
    final target = CreatureDetailRequest("$baseUrl/creature/detail", serviceKey, apiId).toString();
    var result = await Http.get(target);
    if (result['error'] != null) {
      print(result['errorCode']);
      return false;
    } else {
      final searched = result['data'];
      if (kIsWeb) {
        final item = (jsonDecode(searched)['response'])['body']['item'];
        return CreatureDetailResponse(apiId, item['lvbngKrlngNm'], item['lvbngTpcdNm'], item['famlKrlngNm'],
            item['hbttNm'], item['lvbngDscrt'], item['imgUrl1'], item['imgUrl2']);
      } else {
        final item = XMLParser.parseXMLItem(searched);
        return CreatureDetailResponse(
            apiId,
            item.getChild('lvbngKrlngNm')!.text != null ? item.getChild('lvbngKrlngNm')!.text! : "",
            item.getChild('lvbngTpcdNm')!.text != null ? item.getChild('lvbngTpcdNm')!.text! : "",
            item.getChild('famlKrlngNm')!.text != null ? item.getChild('famlKrlngNm')!.text! : "",
            item.getChild('hbttNm')!.text != null ? item.getChild('hbttNm')!.text! : "",
            item.getChild('lvbngDscrt')!.text != null ? item.getChild('lvbngDscrt')!.text! : "",
            item.getChild('imgUrl1')!.text != null ? item.getChild('imgUrl1')!.text! : "",
            item.getChild('imgUrl2')!.text != null ? item.getChild('imgUrl2')!.text! : "",);
      }
    }
  }
}