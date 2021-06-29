import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../dto/post/post_response.dart';

class UserImageCard {
  static List<Widget> buildImageCard(List<PostResponse> posts, double baseSize) {
    final resultList = <Widget>[];
    for (var item in posts) {
      final school = item.schoolName!.replaceFirst("등학교", "");
      final widget = Padding(
        padding: EdgeInsets.all(baseSize / 4),
        child: Container(
          width: baseSize*6,
          height: baseSize*10,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(baseSize / 4)), border: Border.all(color: Colors.black, width: 2.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(baseSize / 8),
                child: Image.network(
                  item.tbImgURL,
                  width: baseSize*5,
                  height: baseSize*3,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: baseSize / 4),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: Colors.black, fontSize: baseSize / 3),
                    ),
                    Text(
                      "$school ${item.nickname}",
                      style: TextStyle(color: Colors.black, fontSize: baseSize / 4),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.red,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: baseSize / 8),
                                  child: Text(
                                    item.likes.toString(),
                                    style: TextStyle(color: Colors.red, fontSize: baseSize / 4),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(CupertinoIcons.eye, color: Colors.black),
                                Padding(
                                  padding: EdgeInsets.only(left: baseSize / 8),
                                  child: Text(
                                    item.views.toString(),
                                    style: TextStyle(color: Colors.black, fontSize: baseSize / 4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: baseSize / 10),
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(color: Colors.black, width: 2.0), shadowColor: Colors.white10),
                              child: Text(
                                "상세보기",
                                style: TextStyle(color: Colors.black, fontSize: baseSize / 5),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      resultList.add(widget);
    }
    return resultList;
  }
  static List<Widget> buildAwardImageCard(List<PostResponse> posts, double baseSize) {
    final resultList = <Widget>[];
    for (var item in posts) {
      var month = item.month!.substring(4);
      if (month[0] == '0') {
        month = month.substring(1);
      }
      final widget = Padding(
        padding: EdgeInsets.all(baseSize / 4),
        child: Container(
          width: baseSize*6,
          height: baseSize*12,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(baseSize / 4)), border: Border.all(color: Colors.black, width: 2.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$month월의 ${item.awardName}", style: TextStyle(color: Colors.black, fontSize: baseSize/2),),
              Padding(
                padding: EdgeInsets.all(baseSize / 8),
                child: Image.network(
                  item.tbImgURL,
                  width: baseSize*5,
                  height: baseSize*3,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: baseSize / 4),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: Colors.black, fontSize: baseSize / 3),
                    ),
                    Text(
                      "${item.nickname}",
                      style: TextStyle(color: Colors.black, fontSize: baseSize / 4),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.red,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: baseSize / 8),
                                  child: Text(
                                    item.likes.toString(),
                                    style: TextStyle(color: Colors.red, fontSize: baseSize / 4),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(CupertinoIcons.eye, color: Colors.black),
                                Padding(
                                  padding: EdgeInsets.only(left: baseSize / 8),
                                  child: Text(
                                    item.views.toString(),
                                    style: TextStyle(color: Colors.black, fontSize: baseSize / 4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: baseSize / 10),
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(color: Colors.black, width: 2.0), shadowColor: Colors.white10),
                              child: Text(
                                "상세보기",
                                style: TextStyle(color: Colors.black, fontSize: baseSize / 5),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      resultList.add(widget);
    }
    return resultList;
  }
}