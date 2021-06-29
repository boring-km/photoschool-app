import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

              ),
            ),
          ),
        ),
      ),
    );
  }

}