import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'hero_dialog_route.dart';

class SingleMessageDialog {
  // ignore: type_annotate_public_apis
  static alert(BuildContext context, String message, {Duration? delayTime}) {
    Navigator.push(context,
        HeroDialogRoute(
            builder: (context) =>
                Center(
                  child: AlertDialog(
                      content: Text(message, style: TextStyle(color: Colors.red, fontSize: 20),)
                  ),
                )
        )
    );
    Future.delayed(delayTime != null ? delayTime : const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }
}