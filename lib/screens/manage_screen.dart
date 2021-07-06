import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/widgets/snackbar.dart';

import '../dto/post/post_response.dart';
import '../services/server_api.dart';
import '../widgets/app_bar_base.dart';
import '../widgets/image_dialog.dart';
import '../widgets/loading.dart';
import '../widgets/user_image_card.dart';

class ManagementScreen extends StatefulWidget {

  final User user;

  ManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {

  late User _user;
  int _postIndex = 0;
  final List<PostResponse> _postList = [];
  bool _isLoaded = false;
  double _baseSize = 100;
  var _postReceived = -1;
  bool _isPostLoading = false;

  @override
  void initState() {
    _user = widget.user;
    Future.delayed(Duration.zero, () async {
      _postList.addAll(await CustomAPIService.getNotApprovedPosts(_postIndex));
      setState(() {
        _isLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext rootContext) {
    var w = MediaQuery.of(rootContext).size.width;
    var h = MediaQuery.of(rootContext).size.height;
    _baseSize = w > h ? h / 10 : w / 15;

    return !_isLoaded ? LoadingWidget.buildLoadingView("로딩중", _baseSize) : Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(
          user: _user,
          image: "manage",
        ),
      ),
      backgroundColor: CustomColors.deepblue,
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
                                          child: Text("로딩중", style: TextStyle(color: Colors.red, fontSize: _baseSize/2),),
                                        )
                                      ],
                                    ),
                                  ),
                                ) : Container();
                              }
                              return Dismissible(
                                  key: Key("${_postList[index].postId}"),
                                  background: UserImageCard.slideRightBackground(_baseSize),
                                  secondaryBackground: UserImageCard.slideLeftBackground(_baseSize),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      await _rejectPost(_postList[index].postId);
                                    } else {
                                      await _approvePost(_postList[index].postId);
                                    }
                                    setState(() {
                                      _postList.removeAt(index);
                                    });
                                    return true;
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      ImageDialog.show(rootContext, _postList[index].imgURL!);
                                    },
                                    child: _buildListViewItem(w, h, context, index),
                                  )
                              );
                            },
                        ),
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

  Widget _buildListViewItem(double w, double h, BuildContext context, int index) {
    final post = _postList[index];
    final regTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(post.regTime).add(Duration(hours: 9)));

    return ListTile(title: Container(
      height: 250,
      color: Color(0xFFFFF3C0),
      child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CachedNetworkImage(
                imageUrl: post.tbImgURL,
                width: w > h ? 300 : 200,
                fit: BoxFit.fitWidth,
                placeholder: (context, url) => Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.creatureGreen, fontSize: _baseSize/2),),),),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Container(
                width: _baseSize * 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("제목: ${post.title}", style: TextStyle(fontSize: _baseSize/2),),
                    Text("작성일자: $regTime", style: TextStyle(fontSize: _baseSize/3),),
                  ],
                ),
              ),
              Container(
                height: _baseSize * (2/3),
                child: ElevatedButton(
                  onPressed: () async {
                    await _approvePost(post.postId);
                    setState(() {
                      _postList.removeAt(index);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green
                  ),
                  child: Container(
                    width: _baseSize * 1.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                            size: _baseSize/2
                        ),
                        Text(
                          "승인",
                          style: TextStyle(fontSize: _baseSize/3),
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
                      _postList.removeAt(index);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red
                  ),
                  child: Container(
                    width: _baseSize * 1.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                            size: _baseSize/2
                        ),
                        Text(
                          "거부",
                          style: TextStyle(fontSize: _baseSize/3),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    ));
  }

  _buildPosts(BuildContext context) async {
    final posts = await CustomAPIService.getNotApprovedPosts(_postIndex);
    _postReceived = posts.length;
    _postList.addAll(posts);
    setState(() {
      _isPostLoading = false;
    });
  }

  _approvePost(int postId) async {
    final result = await CustomAPIService.approvePost(postId);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            backgroundColor: CustomColors.creatureGreen,
            textColor: Colors.white,
            content: "승인되었습니다."
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            content: "에러 발생"
        ),
      );
    }
  }

  _rejectPost(int postId) async {
    final result = await CustomAPIService.rejectPost(postId);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            backgroundColor: CustomColors.red,
            textColor: Colors.white,
            content: "거부되었습니다."
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
            content: "에러 발생"
        ),
      );
    }
  }

}