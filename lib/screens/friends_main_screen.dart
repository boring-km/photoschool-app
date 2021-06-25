import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../res/colors.dart';
import '../widgets/app_bar_base.dart';

class FriendsMainScreen extends StatefulWidget {
  FriendsMainScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _FriendsMainState createState() => _FriendsMainState();
}

class _FriendsMainState extends State<FriendsMainScreen> {
  late User _user;
  double baseSize = 100;

  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    baseSize = w > h ? h / 10 : w / 10;

    return Scaffold(
      backgroundColor: CustomColors.amber,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(
          user: _user,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(baseSize / 2),
        child: Center(
          child: Container(
            width: w * (9 / 10),
            height: h * (9 / 10),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: Colors.white30), borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
              BoxShadow(
                color: Colors.white10,
                offset: Offset(4.0, 4.0),
                blurRadius: 15.0,
                spreadRadius: 1.0,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
