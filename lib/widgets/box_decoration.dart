import 'package:flutter/material.dart';

class CustomBoxDecoration {
  static BoxDecoration buildWhiteBoxDecoration({bool? isTransparent}) {
    return BoxDecoration(
        color: isTransparent == true ? Colors.transparent : Colors.white,
        border: isTransparent == true ? null : Border.all(
            width: 1, color: Colors.white30),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: isTransparent == true ? null : [
          BoxShadow(
            color: Colors.white10,
            offset: Offset(4.0, 4.0),
            blurRadius: 15.0,
            spreadRadius: 1.0,
          )
        ]
    );
  }
}