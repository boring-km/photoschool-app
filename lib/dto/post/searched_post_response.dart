class SearchedPostResponse {
  final String title;
  final String nickname;
  final String apiId;
  final int likes;
  final int views;
  final String imgURL;
  final String regTime;

  SearchedPostResponse(this.title, this.nickname, this.apiId, this.likes, this.views, this.imgURL, this.regTime);

  @override
  String toString() {
    return 'SearchedPostResponse{title: $title, nickname: $nickname, apiId: $apiId, likes: $likes, views: $views, imgURL: $imgURL, regTime: $regTime}';
  }
}