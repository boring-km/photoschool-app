import 'package:flutter/material.dart';
import '../res/colors.dart';

class LoadingWidget {
  static Scaffold buildLoadingView(String message, double baseSize) {
    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      body: Center(
        child: Text(message, style: TextStyle(color: Colors.white, fontSize: baseSize * 3),),
      ),
    );
  }
}