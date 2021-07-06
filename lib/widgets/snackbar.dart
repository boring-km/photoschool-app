import 'package:flutter/material.dart';

class CustomSnackBar {
  static SnackBar show({Color? backgroundColor, Color? textColor, required String content}) {
    return SnackBar(
      backgroundColor: backgroundColor != null ? backgroundColor : Colors.black,
      content: Text(
        content,
        style: TextStyle(color: textColor != null ? textColor : Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}