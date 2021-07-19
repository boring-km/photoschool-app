import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../res/colors.dart';
import '../../utils/auth.dart';
import '../main_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString("nickname") ?? "";

      if (nickname.isNotEmpty) {
        await Authentication.initializeFirebase(context: context);
      }
      setState(() {
        _isLoaded = true;
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    if (!_isLoaded) {
      return Scaffold(
        backgroundColor: CustomColors.deepblue,
        body: SafeArea(
          child: Center(
            child: Lottie.asset('assets/intro2.json', height: 500, repeat: false),
          ),
        ),
      );
    }

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
                    Lottie.asset('assets/intro2.json', height: 500, repeat: false),
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
              )
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
              : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          setState(() { _isSigningIn = true; });
                          var user = await Authentication.signInWithGoogle();
                          setState(() { _isSigningIn = false; });
                          Authentication.signUp(user, context);
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
                    ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('nickname', "테스트 계정");
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => SelectScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text("로그인 없이 이용", style: TextStyle(color: Colors.black),))
                ],
              ),
        ),
      ],
    );
  }
}
