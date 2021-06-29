import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/dto/photos/photo_detail_response.dart';
import 'package:photoschool/dto/post/searched_post_response.dart';
import 'package:photoschool/services/server_api.dart';

import '../res/colors.dart';
import '../widgets/app_bar_base.dart';
import '../widgets/box_decoration.dart';

class FriendsDetailScreen extends StatefulWidget {

  final int _postId;
  final User _user;

  FriendsDetailScreen(this._postId, {Key? key, required User user})
      : _user = user,
        super(key: key);

  @override
  _FriendsDetailScreenState createState() => _FriendsDetailScreenState();
}

class _FriendsDetailScreenState extends State<FriendsDetailScreen> {

  double _baseSize = 100;
  late User _user;
  late SearchedPostResponse _post;

  @override
  void initState() {
    _user = widget._user;
    Future.delayed(Duration.zero,() {
      _searchDetailPost(widget._postId);
    });
    super.initState();
  }

  _searchDetailPost(int postId) async {
    _post = await CustomAPIService.searchDetailPost(postId);
    setState(() {
      print(_post);
    });
  }

  @override
  Widget build(BuildContext context) {

    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    _baseSize = w > h ? h / 10 : w / 10;
    var boxRounded = w > h ? h / 30 : w / 30;

    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(
          user: _user,
          image: "friends",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(_baseSize/3),
          child: Center(
            child: Container(
              decoration: CustomBoxDecoration.buildWhiteBoxDecoration(),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Image.network(
                    _post.imgURL,
                  ),
                  Text(_post.title),
                  Text(_post.nickname),
                  Row(
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}