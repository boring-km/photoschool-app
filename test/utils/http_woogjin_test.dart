import 'package:photoschool/services/woongjin_api.dart';
import 'package:test/test.dart';

void main() {
  test("웅진 백과사전에서 곰을 검색하면...", () async {
    var result = await WoongJinAPIService.searchWJPedia("곰");
    print(result);
  });

  test("웅진 백과사전 상세 검색에서 1550번을 검색하면...", () async {
    var result = await WoongJinAPIService.searchDetailWJPedia(1550);
    print(result.toString());
  });

  test("웅진 포토라이브러리에서 곰을 검색하면...", () async {
    var result = await WoongJinAPIService.searchPhotoLibrary("곰");
    print(result);
  });

  test("웅진 포토라이브러리에서 7064번을 상세 조회하면 검색하면...", () async {
    var result = await WoongJinAPIService.searchPhotoDetail(7064);
    print(result);
  });
}