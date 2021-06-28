class PhotoResponse {
  final String apiId;
  final String imgURL;

  PhotoResponse(this.apiId, this.imgURL);

  @override
  String toString() {
    return 'PhotoResponse{apiId: $apiId, imgURL: $imgURL}';
  }
}