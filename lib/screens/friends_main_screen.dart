import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../res/colors.dart';
import '../services/server_api.dart';
import '../widgets/app_bar_base.dart';
import '../widgets/box_decoration.dart';
import '../widgets/hero_dialog_route.dart';
import '../widgets/user_image_card.dart';

class FriendsMainScreen extends StatefulWidget {
  FriendsMainScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _FriendsMainState createState() => _FriendsMainState();
}

class _FriendsMainState extends State<FriendsMainScreen> {
  late User _user;
  double _baseSize = 100;
  bool _isLoaded = false;
  int _awardReceived = -1;
  int _postReceived = -1;
  int _awardIndex = 0;
  int _postIndex = 0;

  final _awardImageCardList = <Widget>[];
  final _searchedList = <Widget>[];
  final _searchTextController = TextEditingController();

  final _searchTypeList = ['제목', '닉네임', '학교'];
  String _selectedSearchType = '제목';

  final _sortTypeList = ['최신순', '조회수', '좋아요'];
  var _selectedSortType = '최신순';
  bool _isSearched = false;
  bool _isPostsLoading = false;
  bool _isAwardLoading = false;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() async {
    _user = widget._user;
    await Future.delayed(const Duration(milliseconds: 500), () async {
      await _buildPosts(context);
      await _buildAwardView(context);
    });

  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    _baseSize = w > h ? h / 10 : w / 18;
    var buttonWidth = w > h ? w / 15 : h / 15;
    var buttonHeight = w > h ? h / 15 : w / 15;
    var buttonFontSize = w > h ? h / 40 : w / 40;

    return !_isLoaded
        ? Scaffold(
            backgroundColor: CustomColors.creatureGreen,
            body: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: "Friends",
                      child: SvgPicture.asset(
                        'assets/friends.svg',
                        height: h / 2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(_baseSize / 2),
                      child: Text(
                        "로딩중",
                        style: TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black45,
                                  offset: Offset(3.0, 3.0))
                            ],
                            fontSize: buttonFontSize * 3),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: CustomColors.deepblue,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: AppBarTitle(
                user: _user,
                image: "friends",
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(_baseSize / 3),
                child: Center(
                  child: Container(
                    decoration: CustomBoxDecoration.buildWhiteBoxDecoration(),
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Container(
                          width: w * (9 / 10),
                          height: _baseSize,
                          child: Padding(
                            padding: EdgeInsets.only(top: _baseSize / 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                _baseSize / 2)),
                                        primary: CustomColors.lightRed,
                                        onSurface: CustomColors.red),
                                    onPressed: () async {
                                      await _buildSchoolRankDialog(context);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: _baseSize / 8),
                                      child: Container(
                                        height: _baseSize * (2 / 3),
                                        child: Row(
                                          children: [
                                            Hero(
                                              tag: 'school',
                                              child: Icon(
                                                Icons.school,
                                                color: Colors.white,
                                                size: _baseSize / 2,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: _baseSize / 5),
                                              child: Text(
                                                "학교 랭킹",
                                                style: TextStyle(
                                                    fontSize: _baseSize / 3,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: NotificationListener<ScrollEndNotification>(
                                onNotification: (scrollEnd) {
                                  final metrics = scrollEnd.metrics;
                                  if (metrics.atEdge) {
                                    if (metrics.pixels != 0) {
                                      if (_postReceived == -1 || _postReceived == 9) {
                                        _postIndex++;
                                        setState(() {
                                          _isPostsLoading = true;
                                        });
                                        if (_isSearched) {
                                          _searchPosts(_searchTextController.text.isEmpty ? "%" : _searchTextController.text, context);
                                        } else {
                                          _buildPosts(context);
                                        }
                                      } else {
                                        // TODO 필요없는 로직인지 확인 필요
                                        setState(() {
                                          _isPostsLoading = false;
                                        });
                                      }
                                    }
                                  }
                                  return true;
                                },
                                child: ListView(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: _baseSize / 4,
                                        ),
                                        child: Text(
                                          "축하해요!",
                                          style: TextStyle(
                                              fontSize: buttonFontSize * 3,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Expanded(
                                            child: Container(
                                          height: 450,
                                          child: NotificationListener<
                                              ScrollEndNotification>(
                                            onNotification: (scrollEnd) {
                                              final metrics = scrollEnd.metrics;
                                              if (metrics.atEdge) {
                                                if (metrics.pixels != 0) {
                                                  if (_awardReceived == -1 || _awardReceived == 4) {
                                                    setState(() {
                                                      _isAwardLoading = true;
                                                    });
                                                    _awardIndex++;
                                                    _buildAwardView(context);
                                                  } else {
                                                    // TODO 필요없는 로직인지 확인 필요
                                                    setState(() {
                                                      _isAwardLoading = false;
                                                    });
                                                  }
                                                }
                                              }
                                              return true;
                                            },
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: _awardImageCardList.length + 1,
                                                itemBuilder: (context, index) {
                                                  if (index == _awardImageCardList.length) {
                                                    return _isAwardLoading ? Container(
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            CircularProgressIndicator(color: Colors.red,),
                                                            Padding(
                                                              padding: EdgeInsets.all(_baseSize/10),
                                                              child: Text("로딩중", style: TextStyle(color: Colors.red, fontSize: _baseSize/2),),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ) : Container();
                                                  }
                                                  return _awardImageCardList[index];
                                                }),
                                          ),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: w / 12,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                                value: _selectedSearchType,
                                                isExpanded: true,
                                                icon: Icon(Icons
                                                    .arrow_drop_down_circle),
                                                iconEnabledColor:
                                                    CustomColors.creatureGreen,
                                                items: _searchTypeList
                                                    .map((value) {
                                                  return DropdownMenuItem(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                buttonFontSize *
                                                                    1.2),
                                                      ));
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedSearchType =
                                                        value as String;
                                                  });
                                                },
                                              ),
                                            )),
                                        Padding(
                                          padding: EdgeInsets.all(h / 50),
                                          child: Container(
                                            width: w * (2 / 5),
                                            height: buttonHeight,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(h / 40)),
                                                border: Border.all(
                                                    width: 2,
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: h / 80, right: 80),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  border: InputBorder.none,
                                                  icon: Icon(
                                                    Icons.search,
                                                    size: _baseSize / 3,
                                                    color: Colors.black45,
                                                  ),
                                                  labelText: '제목, 닉네임, 학교 입력',
                                                  labelStyle: TextStyle(
                                                      color: Colors.black45),
                                                  fillColor: Colors.black,
                                                ),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: buttonFontSize),
                                                controller:
                                                    _searchTextController,
                                                onSubmitted: (str) async {
                                                  _searchedList.clear();
                                                  _postIndex = 0;
                                                  _searchPosts(str.isEmpty ? "%" : str, context);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints.tightFor(
                                              width: buttonWidth,
                                              height: buttonHeight),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              _searchedList.clear();
                                              _postIndex = 0;
                                              _searchPosts(
                                                  _searchTextController.text.isEmpty ? "%" : _searchTextController.text, context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          h / 50),
                                                ),
                                                primary: CustomColors.orange,
                                                onSurface: Colors.orangeAccent),
                                            child: Text(
                                              "검색",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                        blurRadius: 4.0,
                                                        color: Colors.black45,
                                                        offset:
                                                            Offset(2.0, 2.0))
                                                  ],
                                                  fontSize: buttonFontSize,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: _baseSize / 3),
                                          child: Container(
                                            width: w / 10,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                                value: _selectedSortType,
                                                isExpanded: true,
                                                icon: Icon(
                                                  Icons.sort_rounded,
                                                  size: _baseSize / 2,
                                                ),
                                                iconEnabledColor:
                                                    CustomColors.red,
                                                items:
                                                    _sortTypeList.map((value) {
                                                  return DropdownMenuItem(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                buttonFontSize),
                                                      ));
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedSortType = value as String;
                                                    _postIndex = 0;
                                                    _searchedList.clear();
                                                    _searchPosts(_searchTextController.text.isEmpty ? "%" : _searchTextController.text, context);
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      primary: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              mainAxisSpacing: 10.0,
                                              childAspectRatio: 3 / 4),
                                      itemCount: _searchedList.length + 1,
                                      itemBuilder: (context, index) {
                                        if (_searchedList.length == index) {
                                          return _isPostsLoading  ? Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(color: Colors.blue,),
                                                  Padding(
                                                    padding: EdgeInsets.all(_baseSize/10),
                                                    child: Text("로딩중", style: TextStyle(color: Colors.blue, fontSize: _baseSize/2),),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ) : Container();
                                        }
                                        return _searchedList[index];
                                      },
                                    ),
                                  ],
                                )
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
    );
  }

  _buildAwardView(BuildContext context) async {
    final posts = await CustomAPIService.getAwardPosts(_awardIndex);
    _awardReceived = posts.length;
    var resultList = UserImageCard.buildAwardImageCard(posts, context, _user);
    setState(() {
      _awardImageCardList.addAll(resultList);
      if (_awardReceived < 4) {
        _isAwardLoading = false;
      }
    });
  }

  _buildPosts(BuildContext context) async {
    final posts = await CustomAPIService.getAllPosts(_postIndex);
    _postReceived = posts.length;
    final resultList = UserImageCard.buildImageCard(posts, context, _user);
    setState(() {
      _searchedList.addAll(resultList);
      _isSearched = false;
      _isLoaded = true;
      if (_postReceived < 9) {
        _isPostsLoading = false;
      }
    });
  }

  void _searchPosts(String str, BuildContext context) async {
    String sortType;
    String searchType;
    if (_selectedSearchType == _searchTypeList[0]) {
      searchType = 'title';
    } else if (_selectedSearchType == _searchTypeList[1]) {
      searchType = 'nickname';
    } else {
      searchType = 'school';
    }
    if (_selectedSortType == _sortTypeList[0]) {
      sortType = 'new';
    } else if (_selectedSortType == _sortTypeList[1]) {
      sortType = 'highviews';
    } else {
      sortType = 'highlikes';
    }
    final posts = await CustomAPIService.searchPost(
        searchType, str, sortType, _postIndex);
    _postReceived = posts.length;
    final resultList = UserImageCard.buildImageCard(posts, context, _user);
    setState(() {
      _searchedList.addAll(resultList);
      _isSearched = true;
      if (_postReceived < 9) {
        _isPostsLoading = false;
      }
    });
  }

  _buildSchoolRankDialog(BuildContext context) async {
    var _baseSize = 80.0;
    final schoolList = await CustomAPIService.getSchoolRank();
    final widgetList = <Widget>[];
    for (var i = 0; i < schoolList.length; i++) {
      widgetList.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: _baseSize/2, child: Text("${i+1}등 ", style: TextStyle(fontSize: _baseSize/3),)),
              Container(width: _baseSize*3, child: Text(schoolList[i].schoolName, style: TextStyle(fontSize: _baseSize/3),)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.eye,
                    color: Colors.black,
                  ),
                  Text('${schoolList[i].sumOfViews}', style: TextStyle(fontSize: _baseSize/3),),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: _baseSize/10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.doc,
                      color: Colors.black,
                    ),
                    Text('${schoolList[i].sumOfPosts}', style: TextStyle(fontSize: _baseSize/3),),
                  ],
                ),
              )
            ],
          )
      );
    }
    Navigator.push(context,
        HeroDialogRoute(
            builder: (context) =>
                Center(
                  child: AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: _baseSize/10),
                          child: Hero(
                            tag: "school",
                            child: Icon(
                              Icons.school_rounded,
                              color: Colors.red,
                              size: _baseSize,
                            ),
                          ),
                        ),
                        Text("학교 랭킹", style: TextStyle(color: CustomColors.red, fontSize: _baseSize/2),),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 250,
                          child: SingleChildScrollView(
                            child: Column(
                              children: widgetList,
                            ),
                          ),
                        ),
                        Container(
                          width: _baseSize * 2,
                          height: _baseSize / 2,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: CustomColors.red
                              ),
                              child: Text("닫기", style: TextStyle(fontSize: _baseSize/3),)
                          ),
                        )
                      ],
                    ),
                  ),
                )
        )
    );
  }
}
