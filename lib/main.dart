// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/management/my_post_screen.dart';
import 'screens/user/signin_screen.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  static final navigatorKey = GlobalKey<NavigatorState>();

  Route routes(RouteSettings settings) {
    if (settings.name == "/myPage") {
      return MaterialPageRoute(builder: (_) => MyPostScreen(user: FirebaseAuth.instance.currentUser!));
    } else {
      return MaterialPageRoute(builder: (_) => SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '포토스쿨',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      onGenerateRoute: routes,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'DdoDdo'
      ),
      home: SignInScreen(),
    );
  }
}

