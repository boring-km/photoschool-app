import 'package:photoschool/domain/detail_request.dart';
import 'package:photoschool/domain/search_request.dart';
import 'package:photoschool/utils/http_custom.dart';
import 'package:photoschool/utils/xml_custom.dart';
import 'package:test/test.dart';
import 'package:xml_parser/xml_parser.dart';

void main() async {

  test("어린이 생물도감 목록 검색 API를 HTTP Get으로 호출하면 null이 아니다", () async {
    // given
    final baseUrl = "http://apis.data.go.kr/1400119/ChildService1/childIlstrSearch";
    final serviceKey = "XvIWPXWRvnkJPI4d2FFetPbsFKxe0Tl5eMLAF2Ok7jTEUbRJh0Wl1MPtdrbd0k%2FWKMkeluaCG1fUNauwSD3ORQ%3D%3D";
    final st = 1;
    final keyword = "나무";
    final numOfRows = 10;
    final page = 1;
    final target = SearchRequest(baseUrl, serviceKey, st, keyword, numOfRows, page).toString();

    // when
    var result = await Http.get(target);

    // then
    expect(result['error'], null);
  });

  test("어린이 생물도감 상세 검색 API를 HTTP Get으로 호출하면 null이 아니다", () async {
    // given
    final baseUrl = "http://apis.data.go.kr/1400119/ChildService1/childIlstrInfo";
    final serviceKey = "XvIWPXWRvnkJPI4d2FFetPbsFKxe0Tl5eMLAF2Ok7jTEUbRJh0Wl1MPtdrbd0k%2FWKMkeluaCG1fUNauwSD3ORQ%3D%3D";
    final apiId = 1234;
    final target = DetailRequest(baseUrl, serviceKey, apiId).toString();

    // when
    var result = await Http.get(target);

    // then
    print(result);
    expect(result['error'], null);
  });

  test("어린이 생물도감 목록에서 나무를 검색한 첫번째 결과의 국명은 가는잎조팝나무다", () async {
    // given
    final baseUrl = "http://apis.data.go.kr/1400119/ChildService1/childIlstrSearch";
    final serviceKey = "XvIWPXWRvnkJPI4d2FFetPbsFKxe0Tl5eMLAF2Ok7jTEUbRJh0Wl1MPtdrbd0k%2FWKMkeluaCG1fUNauwSD3ORQ%3D%3D";
    final st = 1;
    final keyword = "나무";
    final numOfRows = 10;
    final page = 1;
    final target = SearchRequest(baseUrl, serviceKey, st, keyword, numOfRows, page).toString();

    // when
    String data = (await Http.get(target))["data"];
    String name = XMLParser.parseXMLList(data)[0].getChild("lvbngKrlngNm")!.text!;

    // then
    expect(name, "가는잎조팝나무");
  });
}
