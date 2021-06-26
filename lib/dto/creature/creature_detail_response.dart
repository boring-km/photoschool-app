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

  CreatureDetailResponse(this.apiId, this.name, this.type, this.familyType, this.habitat, this.detail, this.imgUrl1, this.imgUrl2, this.imgUrl3,);

  @override
  String toString() {
    return 'CreatureDetailResponse{apiId: $apiId, name: $name, type: $type, familyType: $familyType, habitat: $habitat, detail: $detail, imgUrl1: $imgUrl1, imgUrl2: $imgUrl2, imgUrl3: $imgUrl3}';
  }
}