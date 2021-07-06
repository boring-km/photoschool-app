import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';
import '../services/woongjin_api.dart';

import 'hero_dialog_route.dart';

class ImageDialog {
  // ignore: type_annotate_public_apis
  static show(BuildContext parentContext, String imageURL) {
    Navigator.of(parentContext).push(HeroDialogRoute(builder: (context) {
      var w = MediaQuery.of(parentContext).size.width;
      var h = MediaQuery.of(parentContext).size.height;
      var baseWidth = w / 10;
      var baseHeight = h / 10;
      return Center(
        child: AlertDialog(
          backgroundColor: Colors.black45,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("이미지를 확대해보세요!", style: TextStyle(color: CupertinoColors.white),),
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Container(
                  child: Image.network(
                    imageURL,
                    width: w > h ? w * (2/3) : w * (3/4),
                    height: w > h ? h * (2/3) : h * (1/3),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: w / 3,
                        height: h / 3,
                        color: CustomColors.creatureGreen,
                        child: Center(
                          child: Text(
                            "이미지 로딩중: ${(loadingProgress.expectedTotalBytes != null ?
                            (loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100
                                : 100).round()}%",
                            style: TextStyle(color: Colors.white, fontSize: 28),
                          ),
                        ),
                      );
                    },
                  ),
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

  // ignore: type_annotate_public_apis
  static showWithWJDict(BuildContext parentContext, String imageURL, String apiId) async {
    final result = (await WoongJinAPIService.searchPhotoDetail(apiId))[0];
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
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text("이미지를 확대해보세요!", style: TextStyle(color: CupertinoColors.white),),
              ),
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Container(
                  child: Image.network(
                    result.imgURL,
                    width: w > h ? w * (2/3) : w * (3/4),
                    height: w > h ? h * (2/3) : h * (1/3),
                  ),
                ),
              ),
              Text(result.description, style: TextStyle(color: CupertinoColors.white),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("카테고리: ${result.mainCategory} / ${result.subCategory}", style: TextStyle(color: CupertinoColors.white),),
                      Text("출처: ${result.source}", style: TextStyle(color: CupertinoColors.white),),
                    ],
                  ),
                ],
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
