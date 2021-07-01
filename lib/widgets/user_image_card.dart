import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/screens/my_post_screen.dart';
import 'package:photoschool/services/server_api.dart';
import 'package:photoschool/widgets/single_message_dialog.dart';

import '../dto/post/post_response.dart';
import '../screens/friends_detail_screen.dart';
import '../screens/friends_main_screen.dart';
import 'hero_dialog_route.dart';

class UserImageCard {
  static List<Widget> buildImageCard(List<PostResponse> posts, BuildContext context, User user) {
    final resultList = <Widget>[];
    for (var item in posts) {
      final school = item.schoolName == null ? "" : item.schoolName!.replaceFirst("등학교", "");
      final widget = GestureDetector(
        onTap: () async {
          await _route(context, item, user);
        },
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            width: 350,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), border: Border.all(color: Colors.black, width: 2.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Image.network(
                    item.tbImgURL,
                    width: 300,
                    height: 200,
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: 24),),),);
                    },
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
                                  await _route(context, item, user);
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

  static List<Widget> buildAwardImageCard(List<PostResponse> posts, BuildContext context, User user) {
    final resultList = <Widget>[];
    for (var item in posts) {
      var month = item.month!.substring(4);
      if (month[0] == '0') {
        month = month.substring(1);
      }
      final widget = GestureDetector(
        onTap: () async {
          await _route(context, item, user);
        },
        child: Padding(
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
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: 16),),),);
                    },
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
                                await _route(context, item, user);
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

  static List<Widget> buildMyImageCard(List<PostResponse> posts, BuildContext context, User user) {

    final resultList = <Widget>[];
    for (var item in posts) {
      final widget = GestureDetector(
        onTap: () async {
          await _route(context, item, user);
        },
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            height: 300,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), border: Border.all(color: Colors.black, width: 2.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Image.network(
                    item.tbImgURL,
                    width: 300,
                    height: 200,
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: 24),),),);
                    },
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
                        "${item.regTime.substring(0,10)}",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
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
                            PopupMenuButton(
                              onSelected: (result) {
                                if (result == 1) {
                                  _buildTitleChangeDialog(context, item, user);
                                  // CustomAPIService.changePostTitle(title, postId)
                                } else {
                                  // 이미지 바꾸기
                                }
                              },
                              color: CustomColors.friendsYellow,
                              child: Container(
                                color: CustomColors.friendsYellow,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text("수정하기", style: TextStyle(fontSize: 20),),
                                      Icon(Icons.more_vert, color: Colors.black,),
                                    ],
                                  ),
                                ),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 4.0),
                                        child: Icon(
                                          Icons.create,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "제목 수정하기",
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 4.0),
                                        child: Icon(
                                            CupertinoIcons.camera,
                                            color: Colors.black,
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        "이미지 바꾸기",
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
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

  static _route(BuildContext context, PostResponse item, User user) async {
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

  static void _buildTitleChangeDialog(BuildContext rootContext, PostResponse item, User user) {
    var _updateTextController = TextEditingController();
    Navigator.of(rootContext).push(HeroDialogRoute(builder: (context) => Center(
      child: AlertDialog(
        title: Text("제목 수정하기"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                floatingLabelBehavior:FloatingLabelBehavior.never,
                border: UnderlineInputBorder(),
                labelText: '8자 이내로 입력',
                labelStyle: TextStyle(color: Colors.black45),
                fillColor: Colors.black,),
              style: TextStyle(color: Colors.black, fontSize: 20),
              controller: _updateTextController,
              onSubmitted: (text) async {
                final text = _updateTextController.text;
                if (text.length <= 8) {
                  final result = await CustomAPIService.changePostTitle(text, item.postId);
                  print(result);
                  if (result == true) {
                    Navigator.of(context).pop();
                    Navigator.of(rootContext).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MyPostScreen(user: user),
                      ),
                    );
                  } else {
                    SingleMessageDialog.alert(context, "제목을 8자 이내로 입력해주세요");
                  }
                } else {
                  SingleMessageDialog.alert(context, "제목을 8자 이내로 입력해주세요");
                }
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  final text = _updateTextController.text;
                  if (text.length <= 8) {
                    final result = await CustomAPIService.changePostTitle(text, item.postId);
                    print(result);
                    if (result == true) {
                      Navigator.of(context).pop();
                      Navigator.of(rootContext).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MyPostScreen(user: user),
                        ),
                      );
                    } else {
                      SingleMessageDialog.alert(context, "제목을 8자 이내로 입력해주세요");
                    }
                  } else {
                    SingleMessageDialog.alert(context, "제목을 8자 이내로 입력해주세요");
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: CustomColors.friendsYellow
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("수정하기", style: TextStyle(color: Colors.black, fontSize: 20),),
                ))
          ],
        ),
      ),
    )));
  }
}