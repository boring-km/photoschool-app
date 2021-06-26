import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../res/colors.dart';
import '../services/server_api.dart';
import '../utils/auth.dart';
import 'select_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      '포토스쿨 로고 위치',
                      style: TextStyle(
                        color: CustomColors.firebaseYellow,
                        fontSize: 40,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.height / 10)),
                    Text(
                      '포토스쿨',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SDSamlip',
                        fontSize: MediaQuery.of(context).size.width / 15,
                      ),
                    )
                  ],
                ),
              ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSignInButton();
                  }
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.orange,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  var _dialogTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _isSigningIn
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      _isSigningIn = true;
                    });

                    var user =
                        await Authentication.signInWithGoogle(context: context);

                    setState(() {
                      _isSigningIn = false;
                    });

                    if (user != null) {

                      // TODO: 닉네임과 학교 설정 AlertDialog 호출
                      final result = await CustomAPIService.checkUserRegistered();
                      if (result) {
                        final prefs = await SharedPreferences.getInstance();
                        final nickname = await CustomAPIService.getNickName(user);
                        prefs.setString('nickname', nickname);

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SelectScreen(
                                user: user
                            ),
                          ),
                        );
                      } else {
                        _buildUserDialog(context);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage("assets/google-logo.png"),
                          height: 35.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Google 로그인',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ),
        OutlinedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          onPressed: () {
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '로그인 없이 이용',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _buildUserDialog(BuildContext parentContext) {
    showDialog(
        context: parentContext,
        builder: (context) {
          var w = MediaQuery.of(context).size.width / 10;
          var h = MediaQuery.of(context).size.height / 10;

          return AlertDialog(
            title: Text('학교 등록'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  controller: _dialogTextController,
                  decoration: InputDecoration(hintText: "학교 입력"),
                  onSubmitted: (text) async {

                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(h / 8),
                      child: Container(
                        width: w * (2 / 3),
                        height: h * (2 / 3),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                            child: Text(
                              "닫기",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: w / 8, color: Colors.black),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(h / 8),
                      child: Container(
                        width: w * (2 / 3),
                        height: h * (2 / 3),
                        child: ElevatedButton(
                            onPressed: () async {
                              // 학교 등록
                            },
                            style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                            child: Text(
                              "학교 등록",
                              style: TextStyle(fontSize: w / 8, color: Colors.black),
                            )),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
