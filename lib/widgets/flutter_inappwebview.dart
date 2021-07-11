import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        preferredContentMode: UserPreferredContentMode.DESKTOP,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        useWideViewPort: true,
        allowContentAccess: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        ignoresViewportScaleLimits: true,
      ));

  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  late InAppWebView webView;

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: $id ${contextMenuItemClicked.title}");
        });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
    webView = InAppWebView(
      key: webViewKey,
      initialUrlRequest: URLRequest(url: Uri.parse("https://www.google.co.kr/imghp?hl=ko")),
      initialUserScripts: UnmodifiableListView<UserScript>([]),
      initialOptions: options,
      pullToRefreshController: pullToRefreshController,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      onLoadStart: (controller, url) {
        setState(() {
          this.url = url.toString();
          urlController.text = this.url;
        });
      },
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url!;

        if (![
          "http",
          "https",
          "file",
          "chrome",
          "data",
          "javascript",
          "about"
        ].contains(uri.scheme)) {
          if (await canLaunch(url)) {
            // Launch the App
            await launch(
              url,
            );
            // and cancel the request
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
      onLoadStop: (controller, url) async {
        pullToRefreshController.endRefreshing();
        final urlString = url.toString();
        if (urlString.startsWith("https://www.google.co.kr/search?")) {
          final result = await webViewController?.evaluateJavascript(source: "document.getElementsByClassName('gLFyf gsfi')[1].value.split(' ')[0];");
          print("result: $result");
        }

        setState(() {
          this.url = urlString;
          urlController.text = this.url;
        });
      },
      onLoadError: (controller, url, code, message) {
        pullToRefreshController.endRefreshing();
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          pullToRefreshController.endRefreshing();
        }
        setState(() {
          this.progress = progress / 100;
          urlController.text = url;
        });
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        setState(() {
          this.url = url.toString();
          urlController.text = this.url;
        });
      },
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
    );

    try {
      Timer(Duration(seconds: 4), () {
        webViewController?.evaluateJavascript(source: "document.getElementsByClassName('ZaFQO')[0].click();");
      });
      Timer(Duration(seconds: 5), () {
        webViewController?.evaluateJavascript(source: "document.getElementsByClassName('iOGqzf H4qWMc aXIg1b')[0].click();");
        webViewController?.zoomBy(zoomFactor: 3.0);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("InAppWebView")),
        body: SafeArea(
            child: Column(children: <Widget>[
              TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search)
                ),
                controller: urlController,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  var url = Uri.parse(value);
                  if (url.scheme.isEmpty) {
                    url = Uri.parse("https://www.google.com/search?q=$value");
                  }
                  webViewController?.loadUrl(
                      urlRequest: URLRequest(url: url));
                },
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                        width: 400,
                        height: 300,
                        child: webView),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      webViewController?.goBack();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      webViewController?.goForward();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      webViewController?.reload();
                    },
                  ),
                  ElevatedButton(onPressed: () async {
                    await webViewController?.evaluateJavascript(source: "document.getElementById('awyMjb').click();");
                    final result = await webViewController?.isLoading();
                    print(result);
                  }, child: Icon(Icons.cancel))
                ],
              ),
            ])));
  }
}