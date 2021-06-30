import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/screens/friends_main_screen.dart';

import '../dto/creature/creature_detail_response.dart';
import '../dto/dict/dict_detail_response.dart';
import '../dto/post/searched_post_response.dart';
import '../res/colors.dart';
import '../services/public_api.dart';
import '../services/server_api.dart';
import '../services/woongjin_api.dart';
import '../widgets/app_bar_base.dart';
import '../widgets/box_decoration.dart';
import '../widgets/hero_dialog_route.dart';
import '../widgets/loading.dart';

class FriendsDetailScreen extends StatefulWidget {

  final int _postId;
  final User _user;

  FriendsDetailScreen(this._postId, {Key? key, required User user})
      : _user = user,
        super(key: key);

  @override
  _FriendsDetailScreenState createState() => _FriendsDetailScreenState();
}

class _FriendsDetailScreenState extends State<FriendsDetailScreen> {

  double _baseSize = 100;
  late User _user;
  late SearchedPostResponse _post;
  bool _isLoading = true;
  late CreatureDetailResponse _originalCreature;
  late DictDetailResponse _originalDict;

  var _isLiked = false;
  int _likes = 0;

  @override
  void initState() {
    _user = widget._user;
    Future.delayed(Duration.zero,() {
      _searchDetailPost(widget._postId);
    });
    super.initState();
  }

  _searchDetailPost(int postId) async {
    _post = await CustomAPIService.searchDetailPost(postId);
    if (_post.apiId[0] == 'C') {
      _originalCreature = await PublicAPIService.getChildBookDetail(_post.apiId.substring(1), "");
    } else if (_post.apiId[0] == 'P') {
      _originalDict = await WoongJinAPIService.searchDetailWJPedia(_post.apiId.substring(1));
    }
    _isLiked = await CustomAPIService.checkDoLikeBefore(widget._postId);
    _likes = _post.likes;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    _baseSize = w > h ? h / 10 : w / 15;

    var buttonColor = _isLiked ? Colors.red : Colors.white;
    var buttonTextColor = _isLiked ? Colors.white : Colors.red;

    return _isLoading ? LoadingWidget.buildLoadingView("로딩중", _baseSize) : Scaffold(
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
          padding: EdgeInsets.all(_baseSize/3),
          child: Center(
            child: Container(
              decoration: CustomBoxDecoration.buildWhiteBoxDecoration(),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(_baseSize/10),
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
                                      FriendsMainScreen(user: _user)));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: _baseSize/20),
                                      child: Icon(CupertinoIcons.back, color: Colors.white,),
                                    ),
                                    Text("메인화면 이동"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          InteractiveViewer(
                            panEnabled: true,
                            scaleEnabled: true,

                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              _post.imgURL,
                              width: w * (3/4),
                              height: 500,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Container(
                                  width: w * (3/4),
                                  height: 500,
                                  child: Container(
                                    width: w * (3/4),
                                    height: 500,
                                    color: CustomColors.creatureGreen,
                                    child: Center(
                                      child: Text(
                                        "이미지 로딩중: ${(loadingProgress.expectedTotalBytes != null ?
                                        (loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100
                                            : 100).round()}%",
                                        style: TextStyle(color: Colors.white, fontSize: _baseSize),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Text("이미지 호출 에러");
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.search, color: Colors.grey,),
                              Text("확대해서 보기 가능", style: TextStyle(color: Colors.grey),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_post.title, style: TextStyle(fontSize: _baseSize),),
                                  Text(_post.nickname, style: TextStyle(fontSize: _baseSize/2),),
                                  Text(_post.schoolName!, style: TextStyle(fontSize: _baseSize/3),),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            final result = await _doLikeOrNot();
                                            if (result) {
                                              _showLikeDialog(w, h, context);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: buttonColor,
                                            side: BorderSide(color: buttonTextColor, width: 1.0)
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: 8.0),
                                                child: Hero(
                                                  tag: "like",
                                                  child: Icon(
                                                    Icons.thumb_up_alt_rounded,
                                                    color: buttonTextColor,
                                                  ),
                                                ),
                                              ),
                                              Text("좋아요", style: TextStyle(color: buttonTextColor, fontSize: _baseSize/3),)
                                            ],
                                          )
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.thumb_up,
                                              color: Colors.red,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                '$_likes',
                                                style: TextStyle(color: Colors.red, fontSize: 16.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(CupertinoIcons.eye, color: Colors.black),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                _post.views.toString(),
                                                style: TextStyle(color: Colors.black, fontSize: 16.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // TODO 원래 도감 정보로 연결 필요
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLikeDialog(double w, double h, BuildContext context) {
    Navigator.push(context,
        HeroDialogRoute(
            builder: (context) =>
                Center(
                  child: Dialog(
                    backgroundColor: Color(0x01ffffff),
                    child: Hero(
                      tag: 'like',
                      child: Icon(
                        Icons.thumb_up_alt_rounded,
                        color: Colors.red,
                        size: w/4,
                      ),
                    ),
                  ),
                )
        )
    );
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        Navigator.pop(context);
      });
    });
  }

  Future<bool> _doLikeOrNot() async {
    final result = await CustomAPIService.likeOrNotLike(widget._postId);
    print('result: $result');
    if (result) {
      setState(() {
        if (_isLiked) {
          _likes -= 1;
        } else {
          _likes += 1;
        }
        _isLiked = !_isLiked;
      });
      return true;
    } else {
      Navigator.push(context,
          HeroDialogRoute(
              builder: (context) =>
                  Center(
                    child: AlertDialog(
                      content: Text("본인 게시물은 좋아요 클릭이 불가합니다!", style: TextStyle(color: Colors.red, fontSize: _baseSize/3),)
                    ),
                  )
          )
      );
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          Navigator.pop(context);
        });
      });
    }
    return false;
  }

}