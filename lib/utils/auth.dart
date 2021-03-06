import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/main_screen.dart';
import '../screens/management/manage_web_screen.dart';
import '../screens/user/signup_screen.dart';
import '../services/server_api.dart';
import '../widgets/single_message_dialog.dart';

class Authentication {
  static Future<FirebaseApp?> initializeFirebase({
    required BuildContext context,
  }) async {
    var firebaseApp = await Firebase.initializeApp();
    var user = FirebaseAuth.instance.currentUser;
    final result = await signUp(user, context);
    if (result) {
      return firebaseApp;
    } else {
      return null;
    }
  }

  static Future<User?> signInWithGoogle() async {
    var auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      var authProvider = GoogleAuthProvider();
      try {
        final userCredential = await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } on Exception catch (e) {
        print(e);
      }
    } else {

      final googleSignIn = GoogleSignIn();

      final googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final userCredential =
          await auth.signInWithCredential(credential);
          user = userCredential.user;
        } on Exception {
          print("error");
        }
      }
    }

    return user;
  }

  // ignore: type_annotate_public_apis
  static signUp(User? user, BuildContext context) async {
    if (user != null) {
      final result = await CustomAPIService.checkUserRegistered();
      if (result) {
        final prefs = await SharedPreferences.getInstance();
        final result = await CustomAPIService.getNickName(user);
        prefs.setString('nickname', result['nickname']);
        if (result['isAdmin'] == 1) {
          prefs.setBool('isAdmin', true);
        } else {
          prefs.setBool('isAdmin', false);
          if (kIsWeb) {
            SingleMessageDialog.alert(context, "???????????? ????????? ???????????????.");
            await signOut(context: context);
            return false;
          }
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => kIsWeb ? AdminScreen(user: user) : SelectScreen(
                user: user
            ),
          ),
        );
      } else {
        if (kIsWeb) {
          SingleMessageDialog.alert(context, "???????????? ????????? ???????????????.");
          await signOut(context: context);
          return false;
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SignUpScreen(user: user),
            ),
          );
        }
      }
      return true;
    } else {
      return false;
    }
  }

  static Future<void> signOut({required BuildContext context}) async {
    final googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      await FirebaseAuth.instance.signOut();
    } on Exception {
      print("error");
    }
  }
}