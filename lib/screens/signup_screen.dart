import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    var _baseSize = w > h ? h / 10 : w / 20;

    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: Colors.white30), borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
            BoxShadow(
              color: Colors.white10,
              offset: Offset(4.0, 4.0),
              blurRadius: 15.0,
              spreadRadius: 1.0,
            )
          ]),
          width: w * (9/10),
          height: h * (9/10),
        ),
      )
    );
  }

}