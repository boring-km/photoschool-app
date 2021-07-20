import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../res/colors.dart';

class LoadingWidget {
  static Scaffold buildLoadingView(String message, double baseSize) {
    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      body: Center(
        child: message == "로딩중" ?
        Lottie.asset('assets/loading.json', height: 300) :
        Column(
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