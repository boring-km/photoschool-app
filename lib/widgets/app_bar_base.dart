import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/services/server_api.dart';

class AppBarTitle extends StatefulWidget {
  @override
  _AppBarTitleState createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  String _nickname = "";

  @override
  void initState() {
    setNickName();
    super.initState();
  }

  void setNickName() async {
    String temp = await CustomAPIService.getNickName();
    setState(() {
      _nickname = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '포토스쿨',
            style: TextStyle(
              color: CustomColors.firebaseYellow,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO 유저기능 추가
                print("유저 기능");
              },
              child: Text(
                _nickname,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.amber,
                onSurface: CustomColors.firebaseAmber
              ),
            ),
          )
        ],
      ),
    );
  }
}
