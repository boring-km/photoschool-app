import 'dict_main_image_response.dart';

import 'dict_reference.dart';

class DictDetailResponse {

  // 항목 카테고리
  final String category1;
  final String category2;
  final String category3;
  final String categoryNo;

  // 관련 레퍼런스 (이 속에 있는 apiId로 다시 검색 가능해야함)
  final List<DictReference> linkedReferenceList;

  // 기본 정보
  final String apiId;
  final String name;
  final String subName;
  final String description;
  final List<DictMainImageResponse> dictMainImageResponse;
  final String detail;

  DictDetailResponse(this.category1, this.category2, this.category3, this.categoryNo, this.linkedReferenceList, this.apiId, this.name, this.subName, this.description, this.dictMainImageResponse, this.detail);

  @override
  String toString() {
    return 'DictDetailResponse{category1: $category1, category2: $category2, category3: $category3, categoryNo: $categoryNo, linkedReferenceList: $linkedReferenceList, apiId: $apiId, name: $name, subName: $subName, description: $description, dictMainImageResponse: $dictMainImageResponse, detail: $detail}';
  }
}

