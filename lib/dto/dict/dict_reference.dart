class DictReference {
  final String apiId;
  final String name;
  final String order;
  final String dictName;

  DictReference(this.apiId, this.name, this.order, this.dictName);

  @override
  String toString() {
    return 'DictReference{apiId: $apiId, name: $name, order: $order, dictNm: $dictName}';
  }
}