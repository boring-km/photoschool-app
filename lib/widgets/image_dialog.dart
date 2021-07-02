
import 'package:flutter/material.dart';

import 'hero_dialog_route.dart';

class ImageDialog {
  // ignore: type_annotate_public_apis
  static showFullImageDialog(BuildContext parentContext, String imageURL) {
    Navigator.of(parentContext).push(HeroDialogRoute(builder: (context) {
      var w = MediaQuery.of(parentContext).size.width;
      var h = MediaQuery.of(parentContext).size.height;
      var baseWidth = w / 10;
      var baseHeight = h / 10;
      return Center(
        child: AlertDialog(
          backgroundColor: Colors.black45,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  imageURL,
                  width: w * 2/3,
                  height: h * 2/3,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: baseWidth / 8),
                child: Container(
                  width: baseWidth * 2,
                  height: baseHeight * (2 / 3),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                      child: Text(
                        "닫기",
                        style: TextStyle(fontSize: baseWidth / 4, color: Colors.black),
                      )),
                ),
              )
            ],
          ),
        ),
      );
    }));
  }
}
