class CreatureDetailResponse {
  int apiId;
  String name;
  String type;
  String familyType;
  String habitat;
  String detail;
  String imgUrl1;
  String imgUrl2;
  String imgUrl3;
  final bool isExactly;

  CreatureDetailResponse(
      this.apiId,
      this.name,
      this.type,
      this.familyType,
      this.habitat,
      this.detail,
      this.imgUrl1,
      this.imgUrl2,
      this.imgUrl3,
      // ignore: avoid_positional_boolean_parameters
      this.isExactly);

  @override
  String toString() {
    return 'CreatureDetailResponse{apiId: $apiId, name: $name, type: $type, familyType: $familyType, habitat: $habitat, detail: $detail, imgUrl1: $imgUrl1, imgUrl2: $imgUrl2, imgUrl3: $imgUrl3, isExactly: $isExactly}';
  }
}