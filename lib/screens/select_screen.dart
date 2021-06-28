import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../res/colors.dart';
import '../widgets/app_bar_base.dart';
import 'friends_main_screen.dart';
import 'search_creature_screen.dart';

class SelectScreen extends StatefulWidget {

  const SelectScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  late User _user;
  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var boxFontSize = w > h ? h / 15 : w / 15;
    var boxHeight = w > h ? h * (3/5) : h * (4/5);
    var boxWidth = w * (2/5);

    var boxRounded = w > h ? h / 30 : w / 30;

    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(user: _user),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(w / 20),
          child: Center(
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
                              builder: (context) => SearchCreatureScreen(user: _user)
                          )
                      );
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: boxHeight/8, bottom: boxHeight/9),
                          child: Hero(
                            tag: "SelectWiki",
                            child: SvgPicture.asset(
                              'assets/book_reading.svg',
                              height: boxHeight * (1/2),
                            ),
                          ),
                        ),
                        Text(
                          "백과사전\n보기",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black45,
                                  offset: Offset(2.0, 2.0)
                                )
                              ],
                              fontSize: boxFontSize * (3/4),
                              fontFamily: 'DdoDdo',),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(boxRounded)),
                        shadowColor: CustomColors.orangeAccent,
                        primary: CustomColors.orange,
                        onSurface: CustomColors.orangeAccent),
                  ),
                ),
                Padding(padding: EdgeInsets.all(boxRounded)),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: boxWidth, height: boxHeight),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => FriendsMainScreen(user: _user)
                          )
                      );
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: boxHeight/8, bottom: boxHeight/9),
                          child: Hero(
                            tag: "Friends",
                            child: SvgPicture.asset(
                              'assets/friends.svg',
                              height: boxHeight * (1/2),
                            ),
                          ),
                        ),
                        Text(
                          "친구들\n사진 보기",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black45,
                                    offset: Offset(2.0, 2.0)
                                )
                              ],
                              fontSize: boxFontSize * (3/4),
                              fontFamily: 'DdoDdo'),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(boxRounded),
                        ),
                        shadowColor: CustomColors.friendsGreenAccent,
                        primary: CustomColors.creatureGreen,
                        onSurface: CustomColors.friendsGreenAccent,),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
