import 'package:xml_parser/xml_parser.dart';

class XMLParser {
  static List<XmlElement> parseXMLList(String searched) {
    List<XmlElement> itemList = XmlDocument.from(searched)!
        .getChild("response")!
        .getChild("body")!
        .getChild("items")!
        .getChildren("item")!;
    return itemList;
  }
}