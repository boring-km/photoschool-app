import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photoschool/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/main_screen.dart';
import '../screens/user/signup_screen.dart';
import '../services/server_api.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    var firebaseApp = await Firebase.initializeApp();
    var user = FirebaseAuth.instance.currentUser;
    signUp(user, context);
    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
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
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar.show(
                content:
                'The account already exists with a different credential.',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar.show(
                content:
                'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } on Exception {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              content: 'Error occurred using Google Sign-In. Try again.',
            ),
          );
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
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SelectScreen(
                user: user
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignUpScreen(user: user),
          ),
        );
      }
    }
  }

  static Future<void> signOut({required BuildContext context}) async {
    final googleSignIn = GoogleSignIn();
    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isAdmin', false);
      await FirebaseAuth.instance.signOut();
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }
}