import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../dto/creature/creature_detail_request.dart';
import '../dto/creature/creature_detail_response.dart';
import '../dto/creature/creature_request.dart';
import '../dto/creature/creature_response.dart';
import '../utils/http_custom.dart';
import '../utils/xml_custom.dart';

class PublicAPIService {

  static Future<List<CreatureResponse>> getChildBookSearch(String keyword, int page) async {
    final baseUrl = dotenv.env["public_api_list_url"]!;
    final serviceKey = dotenv.env["public_api_key"]!;
    final numOfRows = 8;
    final target = CreatureRequest(baseUrl, serviceKey, 1, keyword, numOfRows, page).toString();
    var creatureList = <CreatureResponse>[];
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
        creatureList.add(CreatureResponse(name, type, apiId));
      }
    }
    return creatureList;
  }

  static Future<Object> getChildBookDetail(int apiId, String keyword) async {
    final baseUrl = dotenv.env["public_api_detail_url"]!;
    final serviceKey = dotenv.env["public_api_key"]!;
    final target = CreatureDetailRequest(baseUrl, serviceKey, apiId).toString();
    var result = await Http.get(target);
    if (result['error'] != null) {
      print(result['errorCode']);
      return false;
    } else {
      final searched = result['data'];
      final item = XMLParser.parseXMLItem(searched);
      return CreatureDetailResponse(
          apiId,
          item.getChild('lvbngKrlngNm')!.text != null ? item.getChild('lvbngKrlngNm')!.text! : "",
          item.getChild('lvbngTpcdNm')!.text!,
          item.getChild('famlKrlngNm')!.text!,
          item.getChild('hbttNm')!.text != null ? item.getChild('hbttNm')!.text! : "",
          item.getChild('lvbngDscrt')!.text != null ? item.getChild('lvbngDscrt')!.text! : "",
          item.getChild('imgUrl1')!.text!,
          item.getChild('imgUrl2')!.text!,
          item.getChild('imgUrl3')!.text!,
          keyword == item.getChild('lvbngTpcdNm')!.text!);
    }
  }


}