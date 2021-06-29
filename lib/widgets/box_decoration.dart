import 'package:flutter/material.dart';

class CustomBoxDecoration {
  static BoxDecoration buildWhiteBoxDecoration() {
    return BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: Colors.white30), borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
      BoxShadow(
        color: Colors.white10,
        offset: Offset(4.0, 4.0),
        blurRadius: 15.0,
        spreadRadius: 1.0,
      )
    ]);
  }
}