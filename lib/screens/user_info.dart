import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/screens/select_screen.dart';
import 'package:photoschool/screens/signin_in.dart';
import 'package:photoschool/services/public_api.dart';
import 'package:photoschool/services/server_api.dart';
import 'package:photoschool/utils/screen_animation.dart';
import 'package:photoschool/widgets/app_bar_base.dart';

import '../utils/auth.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  bool _isSigningOut = false;
  String _userRegisterResult = "";
  String _myPostResult = "";
  String _otherPostsResult = "";
  String _awardPostResult = "";
  String _schoolRankResult = "";
  String _allPostResult = "";
  String _searchResult = "";
  String _apiSearchResult = "";
  String _schoolSearchResult = "";

  var _schoolNameController = TextEditingController();

  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: w / 20,
            right: w / 20,
            bottom: w / 20,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(h / 20),
            children: [
              SizedBox(height: h / 50),
              Text(
                _user.displayName!,
                style: TextStyle(
                  color: CustomColors.firebaseYellow,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: h / 50),
              Text(
                '( ${_user.email!} )',
                style: TextStyle(
                  color: CustomColors.firebaseOrange,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: h / 20),
              _isSigningOut
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.redAccent,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isSigningOut = true;
                  });
                  await Authentication.signOut(context: context);
                  setState(() {
                    _isSigningOut = false;
                  });
                  Navigator.of(context)
                      .pushReplacement(ScreenAnimation.routeTo(SignInScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.only(top: h / 50, bottom: h / 50),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    String result = (await PublicAPIService.getChildBookSearch("소나무", 1)).toString();
                    setState(() {
                      _apiSearchResult = result;
                    });
                  },
                  child: Text("소나무 검색 테스트")
              ),
              Text(_apiSearchResult),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.checkUserRegistered();
                    setState(() {
                      _userRegisterResult = result;
                    });
                  },
                  child: Text("User 등록 테스트")
              ),
              Text(_userRegisterResult),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '서울',
                ),
                controller: _schoolNameController,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.searchSchool(_schoolNameController.text);
                    setState(() {
                      _schoolSearchResult = result;
                    });
                  },
                  child: Text("학교이름을 검색")
              ),
              Text(_schoolSearchResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    final result = await CustomAPIService.getMyPosts(index);
                    setState(() {
                      print(result);
                      _myPostResult = result;
                    });
                  },
                  child: Text("나의 게시물 조회")),
              Text(_myPostResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    int apiId = 1234;
                    final result = await CustomAPIService.getOthersPostBy(apiId, index);
                    setState(() {
                      print(result);
                      _otherPostsResult = result;
                    });
                  },
                  child: Text("1234 도감번호와 관련된 게시물 불러오기")),
              Text(_otherPostsResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    final result = await CustomAPIService.getAwardPosts(index);
                    setState(() {
                      print(result);
                      _awardPostResult = result;
                    });
                  },
                  child: Text("상을 받은 게시물 목록 가져오기")),
              Text(_awardPostResult),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.getSchoolRank();
                    setState(() {
                      print(result);
                      _schoolRankResult = result;
                    });
                  },
                  child: Text("학교 랭킹 구하기")),
              Text(_schoolRankResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    final result = await CustomAPIService.getAllPosts(index);
                    setState(() {
                      print(result);
                      _allPostResult = result;
                    });
                  },
                  child: Text("친구들 사진 기본 검색 결과 불러오기")),
              Text(_allPostResult),
              Padding(padding: EdgeInsets.all(h/50)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(h/50)),
                  Column(
                    children: [
                      Text("최신순으로", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "new", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("제목을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "new", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("닉네임을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "new", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("학교이름을 대구로 검색", style: TextStyle(fontSize: 10.0),)),
                      Text("오래된 순으로", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "old", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("제목을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "old", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("닉네임을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "old", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("학교이름을 대구로 검색", style: TextStyle(fontSize: 10.0),)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(h/50)),
                  Column(
                    children: [
                      Text("조회수 높은 순", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "highviews", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("제목을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "highviews", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("닉네임을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "highviews", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("학교이름을 대구로 검색", style: TextStyle(fontSize: 10.0),)),
                      Text("조회수 낮은 순", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "lowviews", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("제목을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "lowviews", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("닉네임을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "lowviews", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("학교이름을 대구로 검색", style: TextStyle(fontSize: 10.0),)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(h/50)),
                  Column(
                    children: [
                      Text("좋아요 높은 순", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "highlikes", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("제목을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "highlikes", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("닉네임을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "highlikes", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("학교이름을 대구로 검색", style: TextStyle(fontSize: 10.0),)),
                      Text("좋아요 낮은 순", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "lowlikes", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("제목을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "lowlikes", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("닉네임을 테스트로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "lowlikes", index);
                            setState(() {
                              print(result);
                              _searchResult = result;
                            });
                          },
                          child: Text("학교이름을 대구로 검색", style: TextStyle(fontSize: 10.0),)),
                    ],
                  ),
                ],
              ),
              Text("검색결과: $_searchResult"),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => SelectScreen()
                      )
                    );
                  },
                  child: Text("로그인 후 선택 화면"))
            ],
          )
        ),
      ),
    );
  }
}