import 'package:flutter/material.dart';
import '../res/colors.dart';
import '../services/server_api.dart';

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
    var temp = await CustomAPIService.getNickName();
    setState(() {
      _nickname = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var nicknameSize = w > h ? h / 30 : w / 30;

    return Padding(
      padding: EdgeInsets.only(top: h/50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '포토스쿨',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SDSamlip',
              fontSize: 28,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(h/50),
            child: ElevatedButton(
              onPressed: () {
                // TODO 유저기능 추가
                print("유저 기능");
              },
              child: Text(
                _nickname,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'KCCDodam',
                    fontSize: nicknameSize),
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
