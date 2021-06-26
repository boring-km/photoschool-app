class CreatureRequest {
  late String baseUrl;
  late String serviceKey;
  final int st;
  final String keyword;
  final int numOfRows;
  final int pageNo;

  CreatureRequest(this.baseUrl, this.serviceKey, this.st, this.keyword, this.numOfRows, this.pageNo);

  @override
  String toString() {
    return "$baseUrl"
        "?st=$st"
        "&sw=$keyword"
        "&serviceKey=$serviceKey"
        "&numOfRows=$numOfRows"
        "&pageNo=$pageNo";
  }
}