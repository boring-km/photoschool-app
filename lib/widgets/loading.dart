import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../res/colors.dart';

class LoadingWidget {
  static Scaffold buildLoadingView(String message, double baseSize) {
    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: message == "로딩중" ? Lottie.asset('assets/loading.json', height: 300) :
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/196-material-wave-loading.json', height: 300),
            Text(message, style: TextStyle(color: Colors.white, fontSize: baseSize * 2),),
            SizedBox(height: 8,),
            message == "업로드 중" ?
            Text("업로드한 사진은 선생님이 확인한 뒤에 친구들 사진보기에서 볼 수 있어요",
              maxLines: 3,
              style: TextStyle(color: Colors.white, fontSize: baseSize/2),)
                : Container()
          ],
        ),
      ),
    );
  }
}