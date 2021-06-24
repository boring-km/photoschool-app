class DetailRequest {
  late String baseUrl;
  final int q1;
  late String serviceKey;

  DetailRequest(this.baseUrl, this.serviceKey, this.q1);

  @override
  String toString() {
    return "$baseUrl?q1=$q1&serviceKey=$serviceKey";
  }
}