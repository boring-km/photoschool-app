import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/widgets/app_bar_base.dart';

class SelectScreen extends StatefulWidget {
  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1,
                  color: Colors.white30
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white10,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  )
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }

}