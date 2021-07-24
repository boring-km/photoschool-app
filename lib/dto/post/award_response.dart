class Award {
  final int postId;
  final String awardName;
  final String month;

  Award(this.postId, this.awardName, this.month);

  @override
  String toString() {
    return 'Award{postId: $postId, awardName: $awardName, month: $month}';
  }
}