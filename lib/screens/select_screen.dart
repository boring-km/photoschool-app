import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../res/colors.dart';
import '../widgets/app_bar_base.dart';

import 'search_creature_screen.dart';

class SelectScreen extends StatefulWidget {
  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var boxFontSize = w > h ? h / 15 : w / 15;
    var boxHeight = w > h ? h * (3/5) : h * (4/5);
    var boxWidth = w * (2/5);

    var boxRounded = w > h ? h / 30 : w / 30;

    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(w / 20),
          child: Center(
            child: Container(
              width: w * (9 / 10),
              height: h * (9 / 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.white30),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white10,
                      offset: Offset(4.0, 4.0),
                      blurRadius: 15.0,
                      spreadRadius: 1.0,
                    )
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: boxWidth, height: boxHeight),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SearchCreatureScreen()
                          )
                        );
                      },
                      child: Text(
                        "생물도감\n보기",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: boxFontSize,
                            fontFamily: 'SDChild'),
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(boxRounded)),
                          primary: CustomColors.friendsGreen,
                          onSurface: CustomColors.friendsGreenAccent),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(boxRounded)),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: boxWidth, height: boxHeight),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "친구들\n사진 보기",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: boxFontSize,
                            fontFamily: 'SDChild'),
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(boxRounded)),
                          primary: CustomColors.friendsYellow,
                          onSurface: CustomColors.friendsYellowAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
