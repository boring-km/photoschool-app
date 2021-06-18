import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/screens/signin_in.dart';
import 'package:photoschool/services/public_api.dart';
import 'package:photoschool/services/server_api.dart';
import 'package:photoschool/widgets/app_bar_title.dart';

import '../utils/auth.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  bool _isSigningOut = false;
  String _userRegisterResult = "";
  String _myPostResult = "";
  String _otherPostsResult = "";

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(100.0),
            children: [
              SizedBox(height: 8.0),
              Text(
                _user.displayName!,
                style: TextStyle(
                  color: CustomColors.firebaseYellow,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '( ${_user.email!} )',
                style: TextStyle(
                  color: CustomColors.firebaseOrange,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 24.0),
              _isSigningOut
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.redAccent,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isSigningOut = true;
                  });
                  await Authentication.signOut(context: context);
                  setState(() {
                    _isSigningOut = false;
                  });
                  Navigator.of(context)
                      .pushReplacement(_routeToSignInScreen());
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    String result = await PublicAPIService.getChildBookSearch("소나무", 10, 1);
                    print("result: $result");
                  },
                  child: Text("검색 테스트")
              ),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.checkUserRegistered();
                    setState(() {
                      _userRegisterResult = result;
                    });
                  },
                  child: Text("User 등록 테스트")
              ),
              Text(_userRegisterResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    final result = await CustomAPIService.getMyPosts(index);
                    setState(() {
                      print(result);
                      _myPostResult = result;
                    });
                  },
                  child: Text("나의 게시물 조회")),
              Text(_myPostResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    int apiId = 1234;
                    final result = await CustomAPIService.getOthersPostBy(apiId, index);
                    setState(() {
                      print(result);
                      _otherPostsResult = result;
                    });
                  },
                  child: Text("1234 도감번호와 관련된 게시물 불러오기")),
              Text(_otherPostsResult)
            ],
          )
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children:
          // ),
        ),
      ),
    );
  }
}