import 'package:xml_parser/xml_parser.dart';

class XMLParser {
  static List<XmlElement> parseXMLItems(String searched) {
    List<XmlElement> itemList = XmlDocument.from(searched)!
        .getChild("response")!
        .getChild("body")!
        .getChild("items")!
        .getChildren("item")!;
    return itemList;
  }
  
  static XmlElement parseXMLItem(String searched) {
    XmlElement item = XmlDocument.from(searched)!
        .getChild("response")!
        .getChild("body")!
        .getChild("item")!;
    return item;
  }
}