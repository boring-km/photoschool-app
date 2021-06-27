class DictResponse {
  final String apiId;
  final String name;
  final String subName;
  final List<String> imageURLs;
  final String description;
  final bool isExactly;

  DictResponse(this.apiId, this.name, this.subName, this.imageURLs, this.description, this.isExactly);

  @override
  String toString() {
    return 'DictResponse{apiId: $apiId, name: $name, subName: $subName, imageURLs: $imageURLs, description: $description, isExactly: $isExactly}';
  }
}