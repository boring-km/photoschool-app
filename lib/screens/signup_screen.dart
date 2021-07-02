import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/school/school_search_response.dart';
import '../res/colors.dart';
import '../services/server_api.dart';
import '../utils/auth.dart';
import '../widgets/box_decoration.dart';
import '../widgets/single_message_dialog.dart';
import 'select_screen.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {

  SignUpScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  late User _user;

  final _nicknameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _focus = FocusNode();
  final _schoolList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    _user = widget._user;
    _searchSchool("%");
    super.initState();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    var _baseSize = w > h ? h / 10 : w / 10;

    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(_baseSize/2),
          child: Center(
            child: Container(
              decoration: CustomBoxDecoration.buildWhiteBoxDecoration(),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: _baseSize/10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await Authentication.signOut(context: context);
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => SignInScreen(),
                                        ),
                                      );
                                    },
                                    child: Text("로그인 화면으로 돌아가기"),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: _baseSize/4),
                              child: Text("닉네임 입력", style: TextStyle(color: Colors.black, fontSize: _baseSize/2),),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: _baseSize/10),
                              child: Container(
                                width: w / 5,
                                child: TextField(
                                  decoration: InputDecoration(
                                    floatingLabelBehavior:FloatingLabelBehavior.never,
                                    border: UnderlineInputBorder(),
                                    labelText: '닉네임을 6자 이내로 입력',
                                    labelStyle: TextStyle(color: Colors.black45),
                                    fillColor: Colors.black,),
                                  style: TextStyle(color: Colors.black, fontSize: _baseSize/4),
                                  controller: _nicknameController,
                                  onSubmitted: (text) {
                                    FocusScope.of(context).requestFocus(_focus);
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: _baseSize/4),
                              child: Text("학교 입력", style: TextStyle(color: Colors.black, fontSize: _baseSize/2),),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: _baseSize/10),
                                  child: Container(
                                    width: w / 5,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:FloatingLabelBehavior.never,
                                        border: UnderlineInputBorder(),
                                        labelText: '학교 입력',
                                        labelStyle: TextStyle(color: Colors.black45),
                                        fillColor: Colors.black,),
                                      style: TextStyle(color: Colors.black, fontSize: _baseSize/4),
                                      controller: _schoolController,
                                      focusNode: _focus,
                                      onSubmitted: _searchSchool,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: _baseSize/2),
                                  child: Container(
                                    height: _baseSize * 0.8,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        var text = _schoolController.text;
                                        if (text.isEmpty) {
                                          text = "%";
                                        }
                                        _searchSchool(text);
                                      },
                                      child: Text("찾기", style: TextStyle(fontSize: _baseSize/3),),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: _baseSize/10),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26, width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(_baseSize/4))
                                ),
                                width: w/2,
                                height: h/3,
                                child: ListView.builder(
                                    itemCount: _schoolList.length,
                                    itemBuilder: (context, index) => ListTile(
                                      onTap: () {
                                        setState(() {
                                          _selectedIndex = index;
                                        });
                                      },
                                      title: Container(
                                          width: _baseSize * 4,
                                          color: _selectedIndex == index ? CustomColors.lightGreen : Colors.white,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(top: _baseSize/12),
                                                child: Text("${_schoolList[index].region}", style: TextStyle(color: Colors.black45, fontSize: _baseSize/5),),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(bottom: _baseSize/12),
                                                child: Text("${_schoolList[index].schoolName}", style: TextStyle(color: Colors.black, fontSize: _baseSize/3),),
                                              ),
                                            ],
                                          )
                                      ),
                                    )
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: _baseSize/3),
                              child: Container(
                                width: _baseSize*3,
                                height: _baseSize,
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_nicknameController.text.length > 6) {
                                        SingleMessageDialog.alert(context, "닉네임을 6자 이내로 입력해주세요");
                                      } else if (_nicknameController.text.isEmpty) {
                                        SingleMessageDialog.alert(context, "닉네임을 입력해주세요");
                                      } else {
                                        _showConfirmDialog(_nicknameController.text, _schoolList[_selectedIndex] as SchoolSearchResponse, _baseSize);
                                      }
                                    },
                                    child: Text("등록하기", style: TextStyle(fontSize: _baseSize/2),)
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )
            ),
          ),
        ),
      )
    );
  }

  _searchSchool(String schoolName) async {
    _schoolList.clear();
    final result = await CustomAPIService.searchSchool(schoolName);
    setState(() {
      _schoolList.addAll(result);
    });
  }

  _showConfirmDialog(String nickname, SchoolSearchResponse school, double base) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.center,
            child: Text('입력 정보 확인', style: TextStyle(fontSize: base),),
          ),
          content: Padding(
            padding: EdgeInsets.all(base/2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("닉네임: $nickname", style: TextStyle(fontSize: base * 0.7),),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("학교명: ${school.schoolName}", style: TextStyle(fontSize: base * 0.7),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: base, right: base/4),
                      child: Container(
                        width: base*3,
                        height: base*1.5,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: Text("취소하기", style: TextStyle(fontSize: base/2),),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: base, left: base/4),
                      child: Container(
                        width: base*3,
                        height: base*1.5,
                        child: ElevatedButton(
                          onPressed: () async {
                            final isRegistered = await CustomAPIService.registerUser(nickname, school.schoolId);
                            if (isRegistered) {
                              final prefs = await SharedPreferences.getInstance();
                              prefs.setString('nickname', nickname);
                              Navigator.pop(dialogContext);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => SelectScreen(user: _user),
                                ),
                              );
                            }  
                          },
                          child: Text("등록하기", style: TextStyle(fontSize: base/2),),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}