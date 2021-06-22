import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/domain/school_search_response.dart';
import 'package:photoschool/domain/searched_item.dart';
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

  String _searchedDetailPostResult = "";

  String _likeButtonResult = "";

  List<Widget> _myPostImageList = [];

  List<Widget> _othersPostWithApiList = [];

  List<Widget> _awardImageList = [];

  List<Widget> _allPostsImageList = [];

  List<Widget> _searchImageResult = [];

  String _searchedDetailPostImage = "";

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
                    List<SearchedCreature> results = await PublicAPIService.getChildBookSearch("소나무", 1);
                    setState(() {
                      String result = "";
                      for (var item in results) {
                        result += "이름: ${item.name}, 종류: ${item.type}, 도감번호: ${item.apiId}\n";
                      }
                      _apiSearchResult = result;
                    });
                  },
                  child: Text("어린이 생물 도감에서 '소나무'를 검색")
              ),
              Text(_apiSearchResult),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.checkUserRegistered();
                    setState(() {
                      _userRegisterResult = result.toString();
                    });
                  },
                  child: Text("현재 사용자가 등록된 사용자인지 API 서버에서 체크")
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
                    List<SchoolSearchResponse> results = await CustomAPIService.searchSchool(_schoolNameController.text);
                    String result = "";
                    for (var item in results) {
                      result += "학교번호: ${item.schoolId}, 지역: ${item.region}, 학교이름: ${item.schoolName}\n";
                    }
                    setState(() {
                      _schoolSearchResult = result;
                    });
                  },
                  child: Text("학교이름을 API 서버에서 검색")
              ),
              Text(_schoolSearchResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    final result = await CustomAPIService.getMyPosts(index);
                    String text = "조회된 게시물 길이: ${result['numOfPosts']}, 학교 이름: ${result['schoolName']}\n";
                    List<Widget> imageList = [];
                    for (var item in result['posts']) {
                      text += "게시물 번호: ${item.postId}, 게시물 제목: ${item.title}, 좋아요: ${item.likes}, 조회수: ${item.views}, 작성일자/수정일자: ${item.regTime}\n";
                      imageList.add(
                        Image.network(item.tbImgURL, height: 100,)
                      );
                    }
                    setState(() {
                      _myPostResult = text;
                      _myPostImageList = imageList;
                    });
                  },
                  child: Text("내가 작성한 게시물을 API 서버에서 조회")),
              Text(_myPostResult),
              Row(
                children: _myPostImageList,
              ),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    int apiId = 1234;
                    final result = await CustomAPIService.getOthersPostBy(apiId, index);
                    String text = "조회된 게시물 길이: ${result['numOfPosts']}\n";
                    List<Widget> imageList = [];
                    for (var item in result['posts']) {
                      text += "게시물 번호: ${item.postId}, 게시물 제목: ${item.title}, 좋아요: ${item.likes}, 조회수: ${item.views}, 작성일자/수정일자: ${item.regTime}\n";
                      imageList.add(
                          Image.network(item.tbImgURL, height: 100,)
                      );
                    }
                    setState(() {
                      _otherPostsResult = text;
                      _othersPostWithApiList = imageList;
                    });
                  },
                  child: Text("생물도감 번호 (1234)를 보고 촬영한 게시물을 API 서버에서 불러오기 (사진은 Firebase Storage)")),
              Text(_otherPostsResult),
              Row(
                children: _othersPostWithApiList,
              ),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    final result = await CustomAPIService.getAwardPosts(index);
                    String text = "조회된 게시물 길이: ${result['numOfPosts']}\n";
                    List<Widget> imageList = [];
                    for (var item in result['posts']) {
                      text += "게시물 번호: ${item.postId}, 게시물 제목: ${item.title}, 좋아요: ${item.likes}, 조회수: ${item.views}, 작성일자/수정일자: ${item.regTime}\n";
                      text += "상 이름: ${item.awardName}, 상을 받은 유저 닉네임: ${item.nickname}\n\n";
                      imageList.add(Image.network(item.tbImgURL, height: 100,));
                    }
                    setState(() {
                      _awardPostResult = text;
                      _awardImageList = imageList;
                    });
                  },
                  child: Text("상을 받은 게시물을 API서버에서 조회하기 (사진은 Firebase Storage)")),
              Text(_awardPostResult),
              Row(
                children: _awardImageList,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.getSchoolRank();
                    String text = "";
                    for (var i = 0; i < result.length; i++) {
                      text += "학교순위: ${i+1}, 학교지역: ${result[i].region}, 학교이름: ${result[i].schoolName}, 조회수 총합: ${result[i].sumOfViews}, 학생수 합: ${result[i].sumOfStudents}\n";
                    }
                    setState(() {
                      _schoolRankResult = text;
                    });
                  },
                  child: Text("API 서버에서 학교 랭킹 구하기")),
              Text(_schoolRankResult),
              ElevatedButton(
                  onPressed: () async {
                    int index = 0;
                    final result = await CustomAPIService.getAllPosts(index);
                    String text = "게시물 전체 길이: ${result['numOfPosts']}\n";
                    final posts = result['posts'];
                    List<Widget> imageList = [];
                    for (var item in posts) {
                      text += "게시물 번호: ${item.postId}, 게시물 제목: ${item.title}, 좋아요: ${item.likes}, 조회수: ${item.views}, 작성일자/수정일자: ${item.regTime}\n";
                      text += "유저 닉네임: ${item.nickname}\n\n";
                      imageList.add(Image.network(item.tbImgURL, height: 200,));
                    }
                    setState(() {
                      _allPostResult = text;
                      _allPostsImageList = imageList;
                    });
                  },
                  child: Text("API 서버에서 모든 학생들의 기본 게시물 결과 불러오기")),
              Text(_allPostResult),
              Column(
                children: _allPostsImageList,
              ),
              Padding(padding: EdgeInsets.all(h/50)),
              Row(
                children: [
                  Padding(padding: EdgeInsets.all(h/50)),
                  Column(
                    children: [
                      Text("최신순으로", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "new", index);
                            setSearchResult(result);
                          },
                          child: Text("제목을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "new", index);
                            setSearchResult(result);
                          },
                          child: Text("닉네임을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "new", index);
                            setSearchResult(result);
                          },
                          child: Text("학교이름을 '대구'로 검색", style: TextStyle(fontSize: 10.0),)),
                      Text("오래된 순으로", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "old", index);
                            setSearchResult(result);
                          },
                          child: Text("제목을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "old", index);
                            setSearchResult(result);
                          },
                          child: Text("닉네임을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "old", index);
                            setSearchResult(result);
                          },
                          child: Text("학교이름을 '대구'로 검색", style: TextStyle(fontSize: 10.0),)),
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
                            setSearchResult(result);
                          },
                          child: Text("제목을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "highviews", index);
                            setSearchResult(result);
                          },
                          child: Text("닉네임을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "highviews", index);
                            setSearchResult(result);
                          },
                          child: Text("학교이름을 '대구'로 검색", style: TextStyle(fontSize: 10.0),)),
                      Text("조회수 낮은 순", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "lowviews", index);
                            setSearchResult(result);
                          },
                          child: Text("제목을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "lowviews", index);
                            setSearchResult(result);
                          },
                          child: Text("닉네임을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "lowviews", index);
                            setSearchResult(result);
                          },
                          child: Text("학교이름을 '대구'로 검색", style: TextStyle(fontSize: 10.0),)),
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
                            setSearchResult(result);
                          },
                          child: Text("제목을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "highlikes", index);
                            setSearchResult(result);
                          },
                          child: Text("닉네임을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "highlikes", index);
                            setSearchResult(result);
                          },
                          child: Text("학교이름을 '대구'로 검색", style: TextStyle(fontSize: 10.0),)),
                      Text("좋아요 낮은 순", style: TextStyle(fontSize: 20, color: Colors.red),),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("title", "테스트", "lowlikes", index);
                            setSearchResult(result);
                          },
                          child: Text("제목을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("nickname", "테스트", "lowlikes", index);
                            setSearchResult(result);
                          },
                          child: Text("닉네임을 '테스트'로 검색", style: TextStyle(fontSize: 10.0),)),
                      ElevatedButton(
                          onPressed: () async {
                            int index = 0;
                            final result = await CustomAPIService.searchPost("school", "대구", "lowlikes", index);
                            setSearchResult(result);
                          },
                          child: Text("학교이름을 '대구'로 검색", style: TextStyle(fontSize: 10.0),)),
                    ],
                  ),
                ],
              ),
              Text("검색결과: $_searchResult"),
              Row(
                children: _searchImageResult,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.searchDetailPost(1000000001);
                    setState(() {
                      _searchedDetailPostResult = "게시물 제목: ${result.title}\n 작성자 닉네임: ${result.nickname}\n "
                          "도감번호: ${result.apiId}\n 좋아요 수: ${result.likes}\n "
                          "조회수: ${result.views}\n 작성일자/수정일자: ${result.regTime}\n";
                      _searchedDetailPostImage = result.imgURL;
                    });
                  },
                  child: Text("API 서버에서 게시물id가 1000000001인 게시물을 상세보기 조회")),
              Text(_searchedDetailPostResult),
              _searchedDetailPostImage == "" ? Text("로딩 전") : Image.network(_searchedDetailPostImage, height: 200,),
              ElevatedButton(
                  onPressed: () async {
                    final result = await CustomAPIService.likeOrNotLike(1000000001);
                    setState(() {
                      if (result) _likeButtonResult = "좋아요 클릭됨";
                      else _likeButtonResult = "좋아요 클릭 해제됨";
                    });
                  },
                  child: Text("API 서버에서 게시물id 1000000001인 게시물을 좋아요 요청")),
              Text(_likeButtonResult),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
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

  void setSearchResult(result) {
    List<Widget> imageList = [];
    _searchResult = "";
    for (var item in result) {
      _searchResult += "게시물 번호: ${item.postId}, 게시물 제목: ${item.title}, 좋아요: ${item.likes}, 조회수: ${item.views}, 작성일자/수정일자: ${item.regTime}\n";
      _searchResult += "유저 닉네임: ${item.nickname}\n\n";
      imageList.add(Image.network(item.tbImgURL, width: 100,));
    }

    setState(() {
      _searchResult = _searchResult;
      _searchImageResult = imageList;
    });
  }
}