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
  String? month;
  String? schoolName;
  final String regTime;
  final String upTime;

  PostResponse(this.postId, this.title, this.likes, this.views, this.tbImgURL, this.regTime, this.upTime);

  @override
  String toString() {
    return 'PostResponse{postId: $postId, title: $title, likes: $likes, views: $views, tbImgURL: $tbImgURL, nickname: $nickname, apiId: $apiId, imgURL: $imgURL, awardName: $awardName, month: $month, schoolName: $schoolName, regTime: $regTime, upTime: $upTime}';
  }
}