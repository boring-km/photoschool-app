import 'package:xml_parser/xml_parser.dart';

class XMLParser {
  static List<XmlElement> parseXMLItems(String searched) {
    var parentList = XmlDocument.from(searched)!
        .getChild("response")!
        .getChild("body")!
        .getChild("items");
    if (parentList!.getChildren("item") == null) {
      return [];
    }
    return parentList.getChildren("item")!;
  }
  
  static XmlElement? parseXMLItem(String searched) {
    var item = XmlDocument.from(searched)!
        .getChild("response")!
        .getChild("body")!
        .getChild("item");
    return item;
  }
}