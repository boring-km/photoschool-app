import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../res/colors.dart';
import '../screens/my_post_screen.dart';
import '../screens/signin_screen.dart';
import '../utils/auth.dart';
import '../utils/screen_animation.dart';

class AppBarTitle extends StatefulWidget {

  AppBarTitle({Key? key, User? user, String? image})
      : _user = user, _image = image,
        super(key: key);

  final User? _user;
  final String? _image;

  @override
  _AppBarTitleState createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  String _nickname = "";
  bool _isSigningOut = false;
  late User? _user;
  late String? _image;

  Timer? timer;

  @override
  void initState() {
    _user = widget._user;
    _image = widget._image;
    setNickName();
    super.initState();
  }

  void setNickName() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _nickname = prefs.getString('nickname') ?? '닉네임 없음';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var baseSize = w > h ? w / 20 : h / 20;

    var image = Container(
      child: Row(
        children: [
          Hero(tag: "", child: Container()),
        ],
      ),
    );

    if (_image == "creature") {
      image = Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: baseSize/8, horizontal: baseSize/3),
          child: Row(
            children: [
              Hero(
                tag: "SelectWiki",
                child: SvgPicture.asset(
                  'assets/book_reading.svg',
                  height: baseSize/2,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: w/40),
                child: Text("백과사전 보기",
                  style: TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0)
                        )
                      ],
                      fontSize: baseSize/2,),),
              )
            ],
          ),
        ),
      );
    } else if (_image == "friends") {
      image = Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: baseSize/8, horizontal: baseSize/3),
          child: Row(
            children: [
              Hero(
                tag: "Friends",
                child: SvgPicture.asset(
                  'assets/friends.svg',
                  height: h / 20,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: w/40),
                child: Text("친구들 사진보기",
                  style: TextStyle(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          blurRadius: 4.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0)
                      )
                    ],
                    fontSize: baseSize/2,),),
              )
            ],
          ),
        ),
      );
    } else if (_image == "mypost") {
      image = Container(
        decoration: BoxDecoration(
            color: CustomColors.friendsYellow,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(16.0), right: Radius.circular(16.0))
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: baseSize/8, horizontal: baseSize/3),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/manager.svg',
                height: h / 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: w/40),
                child: Text("활동 관리",
                  style: TextStyle(
                    color: Colors.black,
                    shadows: [
                      Shadow(
                          blurRadius: 4.0,
                          color: Colors.white70,
                          offset: Offset(2.0, 2.0)
                      )
                    ],
                    fontSize: baseSize/2,),),
              )
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '포토스쿨',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SDSamlip',
              fontSize: 28,
            ),
          ),
          Row(
            children: [
              image,
            ],
          ),
          Padding(
            padding: EdgeInsets.all(h / 50),
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.friendsYellow,
                borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: w/80),
                    child: Icon(
                      CupertinoIcons.person_alt_circle_fill,
                      color: Colors.black,
                      size: baseSize * (4/7),
                    ),
                  ),
                  _user != null ?
                  _isSigningOut ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ) : PopupMenuButton(
                      onSelected: (result) async {
                        if (result == 1) {
                          Navigator.of(context)
                              .push(ScreenAnimation.routeTo(MyPostScreen(user: _user!)));
                        } else {
                          setState(() {
                            _isSigningOut = true;
                          });
                          await Authentication.signOut(context: context);
                          setState(() {
                            _isSigningOut = false;
                          });
                          Navigator.of(context)
                              .pushReplacement(ScreenAnimation.routeTo(SignInScreen()));
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: baseSize/4),
                        child: Text(
                          _nickname,
                          style: TextStyle(color: Colors.black, fontFamily: 'KCCDodam', fontSize: baseSize/2),
                        ),
                      ),
                      color: CustomColors.lightAmber,
                      offset: Offset(0, 45),
                      // icon: Icon(Icons.menu, color: Colors.black),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Icon(
                                        Icons.manage_accounts,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '활동관리',
                                      style: TextStyle(color: Colors.black, fontSize: baseSize/2),
                                    )
                                  ],
                                )
                            ),
                            PopupMenuItem(
                                value: 2,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Icon(
                                        Icons.logout,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '로그아웃',
                                      style: TextStyle(color: Colors.black, fontSize: baseSize/2),
                                    )
                                  ],
                                ))
                          ]
                  ) : Container()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
