class CreatureResponse {
  final String name;
  final String type;
  final String apiId;

  CreatureResponse(this.name, this.type, this.apiId);

  @override
  String toString() {
    return 'CreatureResponse{name: $name, type: $type, apiId: $apiId}';
  }
}