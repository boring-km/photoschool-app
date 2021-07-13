import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photoschool/screens/painter_image.dart';

import '../dto/post/post_response.dart';
import '../res/colors.dart';
import '../services/server_api.dart';
import '../widgets/app_bar_base.dart';
import '../widgets/box_decoration.dart';
import '../widgets/hero_dialog_route.dart';
import '../widgets/loading.dart';
import '../widgets/single_message_dialog.dart';
import '../widgets/user_image_card.dart';

class MyPostScreen extends StatefulWidget {

  final User _user;
  MyPostScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  @override
  _MyPostScreenState createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {

  double _baseSize = 100;
  late User _user;

  int _postIndex = 0;
  final List _postList = [];
  String _schoolName = "";
  bool _isLoading = true;
  bool _isPostsLoading = false;
  int _postReceived = -1;

  ImagePicker picker = ImagePicker();
  final _updateTextController = TextEditingController();

  File? _imageFileToUpload;
  File? _thumbnailFileToUpload;

  bool _isUploaded = true;

  late PostResponse _post;

  @override
  void initState() {
    _user = widget._user;
    Future.delayed(Duration.zero, () async {
      await Future.delayed(const Duration(milliseconds: 300));
      await _buildPosts(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    _baseSize = w > h ? h / 10 : w / 15;

    if (!_isUploaded) {
      return LoadingWidget.buildLoadingView("업로드중", _baseSize);
    }

    return _isLoading ?
    Scaffold(
      backgroundColor: CustomColors.friendsYellow,
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/manager.svg',
                height: h / 2,
              ),
              Padding(
                padding: EdgeInsets.all(_baseSize/2),
                child: Text("로딩중",
                  style: TextStyle(
                      color: Colors.black,
                      shadows: [
                        Shadow(
                            blurRadius: 4.0,
                            color: Colors.white70,
                            offset: Offset(3.0, 3.0)
                        )
                      ],
                      fontSize: _baseSize),),
              )
            ],
          ),
        ),
      ),
    ) :
    Scaffold(
          backgroundColor: CustomColors.deepblue,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: AppBarTitle(
              user: _user,
              image: "mypost",
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(_baseSize/3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(_baseSize/10),
                  decoration: CustomBoxDecoration.buildWhiteBoxDecoration(),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Container(
                        width: w * 0.9,
                        height: _baseSize/2,
                        child: Text("학교: $_schoolName", style: TextStyle(color: Colors.white, fontSize: _baseSize/3),),
                      ),
                      Expanded(
                        child: NotificationListener<ScrollEndNotification>(
                          onNotification: (scrollEnd) {
                            final metrics = scrollEnd.metrics;
                            if (metrics.atEdge) {
                              if (metrics.pixels != 0) {
                                if (_postReceived == -1 || _postReceived == 9) {
                                  setState(() {
                                    _isPostsLoading = true;
                                    _postIndex++;
                                  });
                                  _buildPosts(context);
                                }
                              }
                            }
                            return true;
                          },
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 2.0,
                                childAspectRatio: w > h ? 3/4 : 3/5),
                            itemCount: _postList.length + 1,
                            itemBuilder: (context, index) {
                              if (_postList.length == index) {
                                return _isPostsLoading ? Container(
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
                              return _postList[index];
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  _buildPosts(BuildContext context) async {
    final result = await CustomAPIService.getMyPosts(_postIndex);
    _schoolName = result['schoolName'] as String;
    var posts = result['posts'] as List<PostResponse>;
    _postReceived = posts.length;
    final resultList = _buildMyImageCard(posts, context, _user);
    setState(() {
      _postList.addAll(resultList);
      _isLoading = false;
      if (_postReceived != 9) {
        _isPostsLoading = false;
      }
    });
  }

  List<Widget> _buildMyImageCard(List<PostResponse> posts, BuildContext context, User user) {
    var w = context.size!.width;
    var h = context.size!.height;

    final resultList = <Widget>[];
    for (var item in posts) {
      final widget = GestureDetector(
        onTap: () async {
          if (item.isApproved == 1 && item.isRejected == 0) {
            await UserImageCard.route(context, item, user);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), border: Border.all(color: Colors.black, width: 2.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
                      child: _buildApproval(item.postId, item.isApproved!, item.isRejected!)
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Image.network(
                    item.tbImgURL,
                    width: w/4,
                    height: h/4,
                    fit: BoxFit.fitHeight,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: 24),),),);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                      Text(
                        "작성일자: ${item.regTime.substring(0,10)}",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        "수정일자: ${item.upTime.substring(0,10)}",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                        item.likes.toString(),
                                        style: TextStyle(color: Colors.red, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(CupertinoIcons.eye, color: Colors.black),
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                        item.views.toString(),
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            PopupMenuButton(
                              onSelected: (result) {
                                if (result == 1) {
                                  _buildTitleChangeDialog(context, item, user);
                                } else if (result == 2) {
                                  _post = item;
                                  _showSelectSource(context);
                                } else {
                                  _buildDeletePostDialog(context, item, user);
                                }
                              },
                              color: CustomColors.friendsYellow,
                              child: Container(
                                color: CustomColors.friendsYellow,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text("수정하기", style: TextStyle(fontSize: 20),),
                                      Icon(Icons.more_vert, color: Colors.black,),
                                    ],
                                  ),
                                ),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.create,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "제목 수정하기",
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          CupertinoIcons.camera,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        "이미지 바꾸기",
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 3,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          CupertinoIcons.trash,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        "이미지 지우기",
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      resultList.add(widget);
    }
    return resultList;
  }

  void _buildTitleChangeDialog(BuildContext rootContext, PostResponse item, User user) {
    Navigator.of(rootContext).push(HeroDialogRoute(builder: (context) => Center(
      child: AlertDialog(
        title: Text("제목 수정하기"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                floatingLabelBehavior:FloatingLabelBehavior.never,
                border: UnderlineInputBorder(),
                labelText: '8자 이내로 입력',
                labelStyle: TextStyle(color: Colors.black45),
                fillColor: Colors.black,),
              style: TextStyle(color: Colors.black, fontSize: 20),
              controller: _updateTextController,
              onSubmitted: (text) async {
                await _onUpdateTitle(_updateTextController.text, item, context, rootContext, user);
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  await _onUpdateTitle(_updateTextController.text, item, context, rootContext, user);
                },
                style: ElevatedButton.styleFrom(
                    primary: CustomColors.friendsYellow
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("수정하기", style: TextStyle(color: Colors.black, fontSize: 20),),
                ))
          ],
        ),
      ),
    )));
  }

  Future<void> _onUpdateTitle(String text, PostResponse item, BuildContext context, BuildContext rootContext, User user) async {
    if (text.length <= 8) {
      final result = await CustomAPIService.changePostTitle(text, item.postId);
      if (result == true) {
        Navigator.of(context).pop();
        Navigator.of(rootContext).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyPostScreen(user: user),
          ),
        );
      } else {
        SingleMessageDialog.alert(context, "제목 변경 실패");
      }
    } else {
      SingleMessageDialog.alert(context, "제목을 8자 이내로 입력해주세요");
    }
  }

  _showSelectSource(BuildContext rootContext) {
    var w = MediaQuery.of(rootContext).size.width;
    var h = MediaQuery.of(rootContext).size.height;

    var baseSize = w > h ? h / 10 : w / 10;
    var baseWidth = w / 10;
    var baseHeight = h / 10;
    var boxRounded = w > h ? h / 30 : w / 30;

    Navigator.of(context).push(HeroDialogRoute(builder: (context) => Center(
      child: AlertDialog(
        title: Text(
          '사진을 촬영하거나 가져오기',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(baseSize / 4),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(boxRounded)), primary: Colors.white, onSurface: Colors.white30),
                      onPressed: () async {
                        final result = await _pickImage(ImageSource.camera);
                        if (result) {
                          setState(() {
                            Navigator.of(context).pop();
                            _isUploaded = false;
                          });
                          _uploadImage(rootContext);
                        } else {
                          SingleMessageDialog.alert(context, "실패");
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(baseSize / 4),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.camera,
                                color: Colors.black,
                                size: baseSize,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: baseSize / 10),
                                child: Text(
                                  "카메라",
                                  style: TextStyle(fontSize: baseSize / 4, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.all(baseSize / 4),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(boxRounded)), primary: Colors.white, onSurface: Colors.white30),
                      onPressed: () async {
                        final result = await _pickImage(ImageSource.gallery);
                        if (result) {
                          setState(() {
                            Navigator.of(context).pop();
                          });
                          _uploadImage(rootContext);
                        } else {
                          SingleMessageDialog.alert(context, "실패");
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(baseSize / 4),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_album,
                                color: Colors.black,
                                size: baseSize,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: baseSize / 10),
                                child: Text(
                                  "갤러리",
                                  style: TextStyle(fontSize: baseSize / 4, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: baseWidth / 4),
              child: Container(
                width: baseWidth * 3,
                height: baseHeight,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                    child: Text(
                      "닫기",
                      style: TextStyle(fontSize: baseWidth / 4, color: Colors.black),
                    )),
              ),
            )
          ],
        ),
      ),
    )));
  }

  Future<bool> _pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      var targetImageFile = File(pickedFile.path);
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PainterImageTest(backgroundImageFile: targetImageFile,)),
      );
      if (result == null) {
        return false;
      }
      final imageFile = result['image'];
      _imageFileToUpload = imageFile;
      _thumbnailFileToUpload = await FlutterNativeImage.compressImage(
        imageFile.path,
        quality: 20,
      );
      _updateTextController.text = result['title'];
      return true;
    } else {
      return false;
    }
  }

  Future<void> _uploadImage(BuildContext rootContext) async {

    if (_imageFileToUpload != null && _thumbnailFileToUpload != null) {

      // 1. storage에 썸네일 및 원본 이미지 저장 후 url 추출
      var realImageRef = FirebaseStorage.instance.ref().child('real/${_post.postId}.png');
      var thumbImageRef = FirebaseStorage.instance.ref().child('thumbnail/${_post.postId}.png');

      final uploadTask1 = realImageRef.putFile(_imageFileToUpload!);
      final snapshot1 = await uploadTask1.whenComplete(() => print("원본 이미지 업로드 완료"));
      final _realImgURL = await snapshot1.ref.getDownloadURL();

      final uploadTask2 = thumbImageRef.putFile(_thumbnailFileToUpload!);
      final snapshot2 = await uploadTask2.whenComplete(() => print("썸네일 이미지 업로드 완료"));
      final _thumbImgURL = await snapshot2.ref.getDownloadURL();

      // 2. 다시 이미지 등록
      final result = await CustomAPIService.updateImage(_post.postId, _thumbImgURL, _realImgURL);
      print(result);

      setState(() {
        _isUploaded = true;
        Navigator.of(rootContext).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyPostScreen(user: _user)
          ),
        );
      });
    }
  }

  _buildDeletePostDialog(BuildContext rootContext, PostResponse item, User user) {
    Navigator.of(rootContext).push(HeroDialogRoute(builder: (context) => Center(
        child: AlertDialog(
          title: Center(child: Text("이미지 지우기")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("정말로 ${item.title} 이미지를 지울까요?", style: TextStyle(color: Colors.red, fontSize: 20),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey
                      ),
                      child: Text("취소")),
                  ElevatedButton(
                      onPressed: () async {
                        await deleteUserImage(item, context, rootContext);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red
                      ),
                      child: Text("삭제")
                  )
                ],
              )
            ],
          ),
        )
    )));
  }

  Future<void> deleteUserImage(PostResponse item, BuildContext context, BuildContext rootContext) async {
    final result = await CustomAPIService.deleteImage(item.postId);
    if (result == true) {
      var realImageRef = FirebaseStorage.instance.ref().child('real/${item.postId}.png');
      var thumbImageRef = FirebaseStorage.instance.ref().child('thumbnail/${item.postId}.png');
      await realImageRef.delete();
      await thumbImageRef.delete();

      Navigator.of(context).pop();
      Navigator.of(rootContext).pushReplacement(
        MaterialPageRoute(
            builder: (context) => MyPostScreen(user: _user)
        ),
      );
    } else {
      SingleMessageDialog.alert(context, "삭제 실패");
    }
  }

  _buildApproval(int postId, int isApproved, int isRejected) {
    var resultText = "";
    var resultBackGroundColor = Colors.yellow;
    var resultTextColor = Colors.black;
    if (isApproved == 1 && isRejected == 0) {
      resultText = "승인됨";
      resultTextColor = Colors.white;
      resultBackGroundColor = Colors.green;
    } else if (isApproved == 0 && isRejected == 1) {
      resultText = "거부됨";
      resultTextColor = Colors.white;
      resultBackGroundColor = Colors.red;
    } else {
      resultText = "승인 대기중";
    }

    return Container(
      width: 90,
      height: 30,
      decoration: BoxDecoration(
        color: resultBackGroundColor,
        borderRadius: BorderRadius.all(Radius.circular(4))
      ),
      child: Center(
        child: Text(resultText, style: TextStyle(color: resultTextColor, fontSize: 20)),
      ),
    );
  }
}