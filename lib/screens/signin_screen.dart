import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/colors.dart';
import '../utils/auth.dart';

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
                    setState(() { _isSigningIn = true; });
                    var user = await Authentication.signInWithGoogle(context: context);
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
      ],
    );
  }
}
