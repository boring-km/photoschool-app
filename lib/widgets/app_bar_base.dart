import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/services/server_api.dart';

class AppBarTitle extends StatelessWidget {

  late String _nickname;

  AppBarTitle(String nickname) {
    _nickname = nickname;
  }

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
        Text(_nickname)
      ],
    );
  }
}