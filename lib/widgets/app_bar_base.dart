import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';

class AppBarTitle extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '포토스쿨',
          style: TextStyle(
            color: CustomColors.firebaseYellow,
            fontSize: 18,
          ),
        ),
        Text("닉네임 위치")
      ],
    );
  }
}