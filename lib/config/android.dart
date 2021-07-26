import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

class AndroidConfig {

  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // ignore: type_annotate_public_apis
  static setAndroidConfig() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      FirebaseMessaging.onBackgroundMessage(_messageHandler);
      await _initializeFirebaseMessaging();
      await _initializeAndroidWebView();
    }
  }

  static _initializeAndroidWebView() async {
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

  static _initializeFirebaseMessaging() async {
    var androidSettings = AndroidInitializationSettings(
      '@mipmap/app_icon',
    );
    var settings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(settings);

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

      if (notification != null && android != null) {
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

  static Future<void> _messageHandler(RemoteMessage message) async {

    var data = message.data;
    final postId = data['postId'];
    FirebaseMessaging.instance.unsubscribeFromTopic("$postId");
    return;
  }

}