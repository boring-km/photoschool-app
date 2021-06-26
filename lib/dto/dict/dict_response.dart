class DictResponse {
  final String apiId;
  final String name;
  final String subName;
  final List<String> imageURLs;
  final String description;

  DictResponse(this.apiId, this.name, this.subName, this.imageURLs, this.description);

  @override
  String toString() {
    return 'DictResponse{apiId: $apiId, name: $name, subName: $subName, imageURL: $imageURLs, description: $description}';
  }
}