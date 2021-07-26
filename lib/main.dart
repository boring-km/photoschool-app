// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/android.dart';
import 'res/colors.dart';

import 'screens/management/manage_web_screen.dart';
import 'screens/management/my_post_screen.dart';
import 'screens/user/signin_screen.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  if (!kIsWeb) {
    await AndroidConfig.setAndroidConfig();
    runApp(MyApp());
  } else {
    runApp(AdminApp());
  }
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: '포토스쿨',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      theme: ThemeData(
          fontFamily: 'DdoDdo',
          backgroundColor: CustomColors.deepblue
      ),
      home: AdminScreen(),
    );
  }
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
        fontFamily: 'DdoDdo',
        backgroundColor: CustomColors.deepblue
      ),
      home: SignInScreen(),
    );
  }
}
