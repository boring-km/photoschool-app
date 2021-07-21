import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../dto/creature/creature_detail_response.dart';
import '../../dto/dict/dict_detail_response.dart';
import '../../dto/dict/dict_response.dart';
import '../../dto/post/searched_post_response.dart';
import '../../res/colors.dart';
import '../../services/public_api.dart';
import '../../services/server_api.dart';
import '../../services/woongjin_api.dart';
import '../../widgets/app_bar_base.dart';
import '../../widgets/box_decoration.dart';
import '../../widgets/hero_dialog_route.dart';
import '../../widgets/loading.dart';
import '../dictionary/creature_detail_screen.dart';
import '../dictionary/pedia_detail_screen.dart';

class FriendsDetailScreen extends StatefulWidget {

  final int _postId;
  final User? _user;

  FriendsDetailScreen(this._postId, {Key? key, User? user})
      : _user = user,
        super(key: key);

  @override
  _FriendsDetailScreenState createState() => _FriendsDetailScreenState();
}

class _FriendsDetailScreenState extends State<FriendsDetailScreen> {

  double _baseSize = 100;
  late User? _user;
  late SearchedPostResponse _post;
  bool _isLoading = true;
  late dynamic _original;

  var _isLiked = false;
  int _likes = 0;
  String _regTime = "";
  String _dictImgUrl = "";
  late DictResponse _pedia;
  Color? buttonTextColor;

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
      _original = await PublicAPIService.getChildBookDetail(_post.apiId.substring(1), "");
    } else if (_post.apiId[0] == 'P') {
      _original = await WoongJinAPIService.searchDetailWJPedia(_post.apiId.substring(1));

      final orgList = await WoongJinAPIService.searchWJPedia((_original as DictDetailResponse).name);
      for (var response in orgList) {
        if (response.apiId ==  _post.apiId.substring(1)) {
          _pedia = response;
          break;
        }
      }

      _dictImgUrl = (await WoongJinAPIService.searchPhotoLibrary((_original as DictDetailResponse).name, (_original as DictDetailResponse).categoryNo))[0].imgURL;
    }
    if (_user != null) {
      final checkResult = await CustomAPIService.checkDoLikeBefore(widget._postId);
      if (checkResult == true) {
        _isLiked = checkResult;
      }
    }
    _likes = _post.likes;
    _regTime = "${_post.regTime.substring(5,10).replaceFirst('-', '월 ')}일";
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
    buttonTextColor = _isLiked ? Colors.white : Colors.red;

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
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(_baseSize/10),
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xC4000000),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: InteractiveViewer(
                                          panEnabled: true,
                                          scaleEnabled: true,
                                          minScale: 0.5,
                                          maxScale: 4,
                                          child: Image.network(
                                            _post.imgURL,
                                            width: w * 2/3,
                                            height: 400,
                                            fit: BoxFit.fitHeight,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                width: w * 2/3,
                                                height: 400,
                                                color: Colors.black,
                                                child: Center(
                                                    child: Lottie.asset('assets/loading.json', height: 400)
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Text("이미지 호출 에러");
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.search, color: Colors.black,),
                                        Text("확대해서 보기 가능", style: TextStyle(color: Colors.black),)
                                      ],
                                    ),
                                    Container(
                                      width: w * 2/3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_post.title, style: TextStyle(fontSize: _baseSize * (3/4)),),
                                              Text(_post.nickname, style: TextStyle(fontSize: _baseSize/2),),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(right: 8.0),
                                                  child: _user != null ? ElevatedButton(
                                                      onPressed: () async {
                                                        final result = await _doLikeOrNot();
                                                        if (result) {
                                                          _showLikeDialog(w, h, context);
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          primary: buttonColor,
                                                          side: BorderSide(color: buttonTextColor!, width: 1.0)
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(right: 8.0),
                                                            child: Hero(
                                                              tag: 'like',
                                                              child: Icon(
                                                                Icons.thumb_up_alt_rounded,
                                                                color: buttonTextColor,
                                                              ),
                                                            ),
                                                          ),
                                                          Text("좋아요", style: TextStyle(color: buttonTextColor, fontSize: _baseSize/3),)
                                                        ],
                                                      )
                                                  ) : Container(),
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
                                    ),
                                    Container(
                                      width: w * 2/3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_post.schoolName!, style: TextStyle(fontSize: _baseSize/3),),
                                          Text("작성일자: $_regTime", style: TextStyle(color: Colors.grey),),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showDetail(context);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: _buildImageView(),
                                      ),
                                      Text(_original.name, style: TextStyle(fontSize: _baseSize/2, color: Colors.black),),
                                      SizedBox(height: _baseSize/8,),
                                      Container(
                                        width: _baseSize * 4,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: _baseSize / 6),
                                            child: Text(
                                              _original.runtimeType == CreatureDetailResponse ? "" : _original.description + _original.description,
                                              style: TextStyle(color: Colors.black, fontSize: _baseSize / 5),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: _baseSize/4),
                                        child: Container(
                                          width: _baseSize*2,
                                          height: _baseSize/2,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 2.0
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.blue,
                                                  blurRadius: 8,
                                                  offset: Offset(1.0, 1.0)
                                              ),
                                              BoxShadow(
                                                color: Colors.white,
                                                offset: Offset(-1.0, -1.0),
                                                blurRadius: 8
                                              ),
                                            ]
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Icon(CupertinoIcons.book_solid, color: Colors.blue,),
                                              Text("상세보기", style: TextStyle(fontSize: _baseSize/3, color: Colors.blue),),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  void _showDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _original.runtimeType == CreatureDetailResponse ?
        CreatureDetailScreen(
            _original,
            user: _user
        ) : PediaDetailScreen(_pedia, user: _user),
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
                        color: buttonTextColor,
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
    if (result == true) {
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

  Image _buildImageView() {
    return _original.runtimeType == CreatureDetailResponse ?
    Image.network(
      (_original as CreatureDetailResponse).imgUrl1,
      width: _baseSize * 4,
      height: 400,
      fit: BoxFit.fitHeight,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.creatureGreen, fontSize: _baseSize/2),),),);
      },
    ) :
    Image.network(
      _dictImgUrl,
      width: _baseSize * 4,
      height: 400,
      fit: BoxFit.fitHeight,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: _baseSize/2),),),);
      },
      errorBuilder: (context, child, progress) {
        return Container(child: Center(child: Text("이미지 없음", style: TextStyle(color: CustomColors.orange, fontSize: _baseSize/2),),),);
      },
    );
  }

}