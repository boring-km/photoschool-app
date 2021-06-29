import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../dto/post/post_response.dart';

class UserImageCard {
  static List<Widget> buildImageCard(List<PostResponse> posts) {
    final resultList = <Widget>[];
    for (var item in posts) {
      final school = item.schoolName == null ? "" : item.schoolName!.replaceFirst("등학교", "");
      final widget = Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          width: 350,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), border: Border.all(color: Colors.black, width: 2.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Image.network(
                  item.tbImgURL,
                  width: 300,
                  height: 200,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: Colors.black, fontSize: 24),
                    ),
                    Text(
                      "$school ${item.nickname}",
                      style: TextStyle(color: Colors.black, fontSize: 20),
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
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    item.likes.toString(),
                                    style: TextStyle(color: Colors.red, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(CupertinoIcons.eye, color: Colors.black),
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    item.views.toString(),
                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(color: Colors.black, width: 2.0), shadowColor: Colors.white10),
                              child: Text(
                                "상세보기",
                                style: TextStyle(color: Colors.black, fontSize: 16),
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

  static List<Widget> buildAwardImageCard(List<PostResponse> posts) {
    final resultList = <Widget>[];
    for (var item in posts) {
      var month = item.month!.substring(4);
      if (month[0] == '0') {
        month = month.substring(1);
      }
      final widget = Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          width: 350,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.0)), border: Border.all(color: Colors.black, width: 2.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$month월의 ${item.awardName}", style: TextStyle(color: Colors.black, fontSize: 24),),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.network(
                  item.tbImgURL,
                  width: 300,
                  height: 200,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: Colors.black, fontSize: 24),
                    ),
                    Text(
                      "${item.nickname}",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Column(
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
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      item.likes.toString(),
                                      style: TextStyle(color: Colors.red, fontSize: 16.0),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(CupertinoIcons.eye, color: Colors.black),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      item.views.toString(),
                                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(color: Colors.black, width: 2.0), shadowColor: Colors.white10),
                            child: Text(
                              "상세보기",
                              style: TextStyle(color: Colors.black, fontSize: 14.0),
                            )),
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