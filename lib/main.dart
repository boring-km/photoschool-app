// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/my_post_screen.dart';
import 'screens/signin_screen.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  if (!kIsWeb) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    await _initializeFirebaseMessaging();
    await _initializeAndroidWebView();
  }
  runApp(MyApp());
}

_initializeAndroidWebView() async {
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      var serviceWorkerController = AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      );
    }
  }
}

_initializeFirebaseMessaging() async {
  if (Platform.isAndroid) {
    var androidSettings = AndroidInitializationSettings(
      '@mipmap/app_icon',
    );
    var settings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(settings);
    print("token: ${await FirebaseMessaging.instance.getToken()}");

    var onMessage = FirebaseMessaging.onMessage;

    onMessage.listen((message) {
      var notification = message.notification!;
      var android = message.notification!.android!;
      final data = message.data;
      final postId = data['postId'];
      final title = data['title'];
      final nickname = data['nickname'];
      FirebaseMessaging.instance.unsubscribeFromTopic("$postId");
      print("front: $postId $title $nickname");

      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android.smallIcon,
              ),
            )
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("check");
      print("확인: ${event.data}");
      MyApp.navigatorKey.currentState!.pushNamed("/myPage");
    });
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
        fontFamily: 'DdoDdo'
      ),
      home: SignInScreen(),
    );
  }
}

Future<void> _messageHandler(RemoteMessage message) async {

  var data = message.data;
  final postId = data['postId'];
  final title = data['title'];
  final nickname = data['nickname'];
  FirebaseMessaging.instance.unsubscribeFromTopic("$postId");
  print("background: $postId $title $nickname");

  // flutterLocalNotificationsPlugin.show(
  //     message.data.hashCode,
  //     message.data['title'],
  //     message.data['body'],
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channel.description,
  //         playSound: false,
  //         autoCancel: true,
  //       ),
  //     )
  // );
  return;
}
