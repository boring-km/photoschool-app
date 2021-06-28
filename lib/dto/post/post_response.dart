class PostResponse {
  final int postId;
  final String title;
  final int likes;
  final int views;
  final String tbImgURL;
  String? nickname;
  String? apiId;
  String? imgURL;
  String? awardName;
  final String regTime;

  PostResponse(this.postId, this.title, this.likes, this.views, this.tbImgURL, this.regTime);
}