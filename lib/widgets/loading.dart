import 'package:flutter/material.dart';
import '../res/colors.dart';

class LoadingWidget {
  static Scaffold buildLoadingView(String message, double baseSize) {
    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: baseSize * 2,
                height: baseSize * 2,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 8.0,)
            ),
            Text(message, style: TextStyle(color: Colors.white, fontSize: baseSize * 2.5),),
          ],
        ),
      ),
    );
  }
}