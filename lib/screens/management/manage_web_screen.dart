import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../dto/post/post_response.dart';
import '../../res/colors.dart';
import '../../services/public_api.dart';
import '../../services/server_api.dart';
import '../../services/woongjin_api.dart';
import '../../widgets/image_dialog.dart';
import '../../widgets/loading.dart';
import '../../widgets/snackbar.dart';

class AdminScreen extends StatefulWidget {

  final User? user;

  const AdminScreen({Key? key, this.user}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();

}

class _AdminScreenState extends State<AdminScreen> {

  User? user;
  int _postIndex = 0;
  final List<PostResponse> _postList = [];
  final List<dynamic> _dictNameList = [];
  bool _isLoaded = false;
  double _baseSize = 100;
  var _postReceived = -1;
  bool _isPostLoading = false;

  @override
  void initState() {
    user = widget.user;
    Future.delayed(Duration.zero, () async {
      await getPosts();
    });
    super.initState();
  }

  Future<void> getPosts() async {
    final firstTime = DateTime.now();
    final posts = await CustomAPIService.getNotApprovedPosts(_postIndex);
    _dictNameList.addAll(await _setDictNameList(posts));
    _postList.addAll(posts);
    final passedTime = firstTime.difference(DateTime.now());
    if (passedTime < Duration(seconds: 2)) {
      await Future.delayed(Duration(seconds: 2) - passedTime);
    }
    setState(() {
      _isLoaded = true;
    });
  }

  Future<List> _setDictNameList(List<PostResponse> posts) async {
    final resultList = [];
    for (var post in posts) {
      var _original;
      if (post.apiId![0] == 'C') {
        _original = await PublicAPIService.getChildBookDetail(post.apiId!.substring(1), "");
      } else if (post.apiId![0] == 'P') {
        _original = await WoongJinAPIService.searchDetailWJPedia(post.apiId!.substring(1));
      }
      resultList.add(_original.name);
    }
    return resultList;
  }

  @override
  Widget build(BuildContext rootContext) {
    var w = MediaQuery.of(rootContext).size.width;
    var h = MediaQuery.of(rootContext).size.height;
    _baseSize = w > h ? h / 10 : w / 15;

    return !_isLoaded ? LoadingWidget.buildLoadingView("?????????", _baseSize) : Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Center(
          child: Text("???????????? ????????? ?????????",
            style: TextStyle(
              fontSize: _baseSize/3,
              shadows: [
                Shadow(
                    blurRadius: 4.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0)
                )
              ],
            ),),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
                width: w,
                height: h * (7/8),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: _refresh,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(Icons.refresh, color: Colors.white,),
                                  Text("????????????"),
                                ],
                              ))
                        ],
                      ),
                    ),
                    Expanded(
                        child: NotificationListener<ScrollEndNotification>(
                            onNotification: (scrollEnd) {
                              final metrics = scrollEnd.metrics;
                              if (metrics.atEdge) {
                                if (metrics.pixels != 0) {
                                  if (_postReceived == -1 || _postReceived == 10) {
                                    _postIndex++;
                                    setState(() {
                                      _isPostLoading = true;
                                    });
                                    _buildPosts(rootContext);
                                  }
                                }
                              }
                              return true;
                            },
                            child: ListView.builder(
                              itemCount: _postList.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _postList.length) {
                                  return _isPostLoading ? Container(
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          CircularProgressIndicator(color: Colors.red,),
                                          Padding(
                                            padding: EdgeInsets.all(_baseSize/10),
                                            child: Text("?????????", style: TextStyle(color: Colors.red, fontSize: _baseSize/2),),
                                          )
                                        ],
                                      ),
                                    ),
                                  ) : Container();
                                }
                                return _buildListViewItem(w, h, rootContext, context, index);
                              },
                            )
                        )
                    )
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListViewItem(double w, double h, BuildContext rootContext, BuildContext context, int index) {
    final post = _postList[index];
    final regTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(post.regTime).add(Duration(hours: 9)));
    final upTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(post.upTime).add(Duration(hours: 9)));

    return Container(
      height: 180,
      color: CustomColors.white,
      child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  ImageDialog.show(rootContext, _postList[index].imgURL!);
                },
                child: CachedNetworkImage(
                  imageUrl: post.tbImgURL,
                  width: _baseSize*2,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => Container(child: Center(child: Text("?????????", style: TextStyle(color: CustomColors.creatureGreen, fontSize: _baseSize/2),),),),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Container(
                width: _baseSize * 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${post.title}", style: TextStyle(fontSize: _baseSize/3),),
                    SizedBox(height: _baseSize/8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.book_solid, color: CustomColors.creatureGreen, size: _baseSize/4,),
                        SizedBox(width: _baseSize/8,),
                        Text("?????? ??????: ${_dictNameList[index]}", style: TextStyle(fontSize: _baseSize/4),),
                      ],
                    ),
                    SizedBox(height: _baseSize/6,),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, color: Colors.red,),
                        SizedBox(width: _baseSize / 16,),
                        Text("${post.likes}"),
                        SizedBox(width: _baseSize / 8,),
                        Icon(CupertinoIcons.eye, color: Colors.black,),
                        SizedBox(width: _baseSize / 16,),
                        Text("${post.views}")
                      ],
                    )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("?????????: ${post.nickname}", style: TextStyle(color: Colors.black, fontSize: _baseSize/5),),
                  Text("?????? ?????????: $regTime", style: TextStyle(color: Colors.black38, fontSize: _baseSize/6),),
                  Text("????????? ??????: $upTime", style: TextStyle(color: Colors.black38, fontSize: _baseSize/6),),
                ],
              ),
              Container(
                height: _baseSize * (2/3),
                child: ElevatedButton(
                  onPressed: () async {
                    await _approvePost(post.postId);
                    setState(() {
                      _dictNameList.removeAt(index);
                      _postList.removeAt(index);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green
                  ),
                  child: Container(
                    width: _baseSize,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                            size: _baseSize/3
                        ),
                        Text(
                          "??????",
                          style: TextStyle(fontSize: _baseSize/4),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: _baseSize * (2/3),
                child: ElevatedButton(
                  onPressed: () async {
                    await _rejectPost(post.postId);
                    setState(() {
                      _dictNameList.removeAt(index);
                      _postList.removeAt(index);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red
                  ),
                  child: Container(
                    width: _baseSize,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                            size: _baseSize/3
                        ),
                        Text(
                          "??????",
                          style: TextStyle(fontSize: _baseSize/4),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  _buildPosts(BuildContext context) async {
    final posts = await CustomAPIService.getNotApprovedPosts(_postIndex);
    _postReceived = posts.length;
    _dictNameList.addAll(await _setDictNameList(posts));
    _postList.addAll(posts);
    setState(() {
      _isPostLoading = false;
    });
  }

  _approvePost(int postId) async {
    final result = await CustomAPIService.sendApproval(postId, "approve");
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            backgroundColor: CustomColors.creatureGreen,
            textColor: Colors.white,
            content: "?????????????????????."
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            content: "?????? ??????"
        ),
      );
    }
  }

  _rejectPost(int postId) async {
    final result = await CustomAPIService.sendApproval(postId, "reject");
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            backgroundColor: CustomColors.red,
            textColor: Colors.white,
            content: "?????????????????????."
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            content: "?????? ??????"
        ),
      );
    }
  }

  Future<void> _refresh() async {
    _postIndex = 0;
    _postList.clear();
    _dictNameList.clear();
    _buildPosts(context);
  }

}