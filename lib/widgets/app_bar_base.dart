import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';
import '../screens/signin_screen.dart';
import '../services/server_api.dart';
import '../utils/auth.dart';
import '../utils/screen_animation.dart';

class AppBarTitle extends StatefulWidget {

  AppBarTitle({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _AppBarTitleState createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  String _nickname = "";
  bool _isSigningOut = false;
  late User _user;

  @override
  void initState() {
    _user = widget._user;
    setNickName();
    super.initState();
  }

  void setNickName() async {
    var temp = await CustomAPIService.getNickName(_user);
    setState(() {
      _nickname = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var nicknameSize = w > h ? h / 30 : w / 30;

    return Padding(
      padding: EdgeInsets.only(top: h / 50),
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
          Padding(
            padding: EdgeInsets.all(h / 50),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: w/80),
                    child: Text(
                      _nickname,
                      style: TextStyle(color: Colors.black, fontFamily: 'KCCDodam', fontSize: nicknameSize),
                    ),
                  ),
                  _isSigningOut
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ) : PopupMenuButton(
                      onSelected: (result) async {
                        if (result == 1) {
                          print("활동관리");
                        } else {
                          print("로그아웃");
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
                      color: CustomColors.lightAmber,
                      offset: Offset(0, 45),
                      icon: Icon(Icons.menu, color: Colors.black),
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
                                      style: TextStyle(color: Colors.black, fontSize: nicknameSize),
                                    )
                                  ],
                                )),
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
                                      style: TextStyle(color: Colors.black, fontSize: nicknameSize),
                                    )
                                  ],
                                ))
                          ])
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
