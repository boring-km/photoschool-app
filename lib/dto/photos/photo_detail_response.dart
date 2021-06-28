class PhotoDetailResponse {
  final String apiId;
  final String name;
  final String source;
  final String thumbURL;
  final String imgURL;
  final String mainCategory;
  final String subCategory;
  final String description;

  PhotoDetailResponse(this.apiId, this.name, this.source, this.thumbURL, this.imgURL, this.mainCategory, this.subCategory, this.description);

  @override
  String toString() {
    return 'PhotoDetailResponse{apiId: $apiId, name: $name, source: $source, thumbURL: $thumbURL, imgURL: $imgURL, mainCategory: $mainCategory, subCategory: $subCategory, description: $description}';
  }
}