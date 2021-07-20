import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../dto/post/post_response.dart';
import '../res/colors.dart';
import '../screens/friends/friends_detail_screen.dart';
import '../screens/friends/friends_main_screen.dart';

class UserImageCard {
  static List<Widget> buildImageCard(List<PostResponse> posts, BuildContext context, User? user) {

    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    var base = w > h ? w / 10 : h / 10;

    final resultList = <Widget>[];
    for (var item in posts) {
      final school = item.schoolName == null ? "" : item.schoolName!.replaceFirst("등학교", "");
      final widget = GestureDetector(
        onTap: () async {
          await route(context, item, user);
        },
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: CustomColors.white,
              borderRadius: BorderRadius.all( Radius.circular(40), ),
              boxShadow: [
                BoxShadow(
                  color: CustomColors.creatureGreen,
                  offset: Offset(2.0, 2.0),
                  blurRadius: 10.0,
                  spreadRadius: 1.0, ),
                BoxShadow(
                  color: CustomColors.creatureGreen,
                  offset: Offset(-2.0, -2.0),
                  blurRadius: 1.0, spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(base/10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.network(
                      item.tbImgURL,
                      width: base * 3,
                      height: base * 2,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: base * 3,
                          height: base * 2,
                          child: Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(color: CustomColors.orange,),
                              ),
                              Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: 24),),
                            ],
                          ),),);
                      },
                    ),
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
                                onPressed: () async {
                                  await route(context, item, user);
                                },
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
        ),
      );
      resultList.add(widget);
    }
    return resultList;
  }

  static List<Widget> buildAwardImageCard(List<PostResponse> posts, BuildContext context, User? user) {

    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    var base = w > h ? w / 10 : h / 10;

    final resultList = <Widget>[];
    for (var item in posts) {
      var month = item.month!.substring(4);
      var awardColor = Colors.black;
      if (item.awardName!.substring(0,3) == "좋아요") {
        awardColor = CustomColors.lightRed;
      } else if (item.awardName!.substring(0,3) == "조회수") {
        awardColor = CustomColors.lightblue;
      }

      if (month[0] == '0') {
        month = month.substring(1);
      }
      final widget = GestureDetector(
        onTap: () async {
          await route(context, item, user);
        },
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: CustomColors.white,
              borderRadius: BorderRadius.all( Radius.circular(40), ),
              boxShadow: [
                BoxShadow(
                  color: awardColor,
                  offset: Offset(2.0, 2.0),
                  blurRadius: 10.0,
                  spreadRadius: 1.0, ),
                BoxShadow(
                  color: awardColor,
                  offset: Offset(-2.0, -2.0),
                  blurRadius: 1.0, spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: base * (2/5), right: base * (2/5), bottom: base / 10),
                  child: Container(
                    decoration: BoxDecoration(
                        color: awardColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(base / 8),
                            bottomRight: Radius.circular(base / 8))),
                    height: base / 3,
                    child: Center(
                      child: Text(
                        "$month월의 ${item.awardName}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: base/4),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.network(
                      item.tbImgURL,
                      width: base * 3,
                      height: base * 2,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: base * 3,
                          height: base * 2,
                          child: Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(color: CustomColors.orange,),
                              ),
                              Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: 16),),
                            ],
                          ),),);
                      },
                    ),
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
                              onPressed: () async {
                                await route(context, item, user);
                              },
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
        ),
      );
      resultList.add(widget);
    }
    return resultList;
  }

  // ignore: type_annotate_public_apis
  static route(BuildContext context, PostResponse item, User? user) async {
    var type = context.widget.runtimeType.toString();
    if (type == "FriendsMainScreen") {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
          FriendsDetailScreen(item.postId, user: user)));
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
          FriendsMainScreen(user: user)));
    } else {
      // others
      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
          FriendsDetailScreen(item.postId, user: user)));
    }
  }

  static Widget slideRightBackground(double baseSize) {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: baseSize,
            ),
            Text(
              " 승인",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: baseSize/2
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  static Widget slideLeftBackground(double baseSize) {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: baseSize
            ),
            Text(
              " 거부",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: baseSize/2
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}