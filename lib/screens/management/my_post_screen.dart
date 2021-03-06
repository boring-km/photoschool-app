import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../dto/post/post_response.dart';
import '../../res/colors.dart';
import '../../services/server_api.dart';
import '../../widgets/app_bar_base.dart';
import '../../widgets/hero_dialog_route.dart';
import '../../widgets/loading.dart';
import '../../widgets/painter_image.dart';
import '../../widgets/single_message_dialog.dart';
import '../../widgets/user_image_card.dart';

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
  final _postList = [];
  String _schoolName = "";
  bool _isLoading = true;
  bool _isPostsLoading = false;
  int _postReceived = -1;

  ImagePicker picker = ImagePicker();
  final _updateTextController = TextEditingController();

  File? _imageFileToUpload;
  File? _thumbnailFileToUpload;
  File? _orgImageFile;

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
      return LoadingWidget.buildLoadingView("????????? ???", _baseSize);
    }

    return _isLoading ?
    Scaffold(
      backgroundColor: CustomColors.friendsYellowAccent,
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
                child: Text("?????????",
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
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Container(
                        width: w * 0.9,
                        height: _baseSize/2,
                        child: Row(
                          children: [
                            Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: _baseSize/2,
                            ),
                            SizedBox(width: 15,),
                            Text("$_schoolName", style: TextStyle(color: Colors.white, fontSize: _baseSize/3),),
                          ],
                        ),
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
                                childAspectRatio: w > h ? 7/10 : 1/2),
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
                                          child: Text("?????????", style: TextStyle(color: Colors.blue, fontSize: _baseSize/2),),
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
    final posts = result['posts'] as List<PostResponse>;
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
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    var base = w > h ? w / 10 : h / 10;

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
            decoration: BoxDecoration(color: CustomColors.white, borderRadius: BorderRadius.all(Radius.circular(16)), ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildApproval(item.postId, item.isApproved!, item.isRejected!),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      item.tbImgURL,
                      width: base * 3,
                      height: base * 2,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(child: Center(child: Text("?????????", style: TextStyle(color: CustomColors.orange, fontSize: 24),),),);
                      },
                    ),
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
                        "????????????: ${item.regTime.substring(0,10)}",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        "????????????: ${item.upTime.substring(0,10)}",
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
                              onSelected: (result) async {
                                await setUpdateMenu(item, context, result!, user);
                              },
                              color: CustomColors.friendsYellow,
                              child: Container(
                                color: CustomColors.friendsYellow,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text("????????????", style: TextStyle(fontSize: 20),),
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
                                        "?????? ????????????",
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
                                          Icons.camera,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "?????? ?????????",
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
                                          CupertinoIcons.camera,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        "????????? ?????????",
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 4,
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
                                        "????????? ?????????",
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

  Future<void> setUpdateMenu(PostResponse item, BuildContext context, Object result, User user) async {
    if (item.month != null) {
      SingleMessageDialog.alert(context, "?????? ???????????? ??????/????????? ???????????????");
    } else {
      if (result == 1) {
        _buildTitleChangeDialog(context, item, user);
      } else if (result == 2) {
        _post = item;
        final result = await _pickImage(ImageSource.gallery, isRepainting: true, context: context);
        if (result) {
          setState(() {
            _isUploaded = false;
          });
          _uploadImage(context);
        } else {
          SingleMessageDialog.alert(context, "?????????");
        }
      } else if (result == 3) {
        _post = item;
        _showSelectSource(context);
      } else if (result == 4) {
        _buildDeletePostDialog(context, item, user);
      }
    }
  }

  void _buildTitleChangeDialog(BuildContext rootContext, PostResponse item, User user) {
    Navigator.of(rootContext).push(HeroDialogRoute(builder: (context) => Center(
      child: AlertDialog(
        title: Text("?????? ????????????"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                floatingLabelBehavior:FloatingLabelBehavior.never,
                border: UnderlineInputBorder(),
                labelText: '8??? ????????? ??????',
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
                  child: Text("????????????", style: TextStyle(color: Colors.black, fontSize: 20),),
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
        FirebaseMessaging.instance.subscribeToTopic("${item.postId}");

        Navigator.of(context).pop();
        Navigator.of(rootContext).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyPostScreen(user: user),
          ),
        );
      } else {
        SingleMessageDialog.alert(context, "?????? ?????? ??????");
      }
    } else {
      SingleMessageDialog.alert(context, "????????? 8??? ????????? ??????????????????");
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
          '????????? ??????????????? ????????????',
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
                        final result = await _pickImage(ImageSource.camera, context: context);
                        Navigator.of(context).pop();
                        if (result) {
                          setState(() {
                            _isUploaded = false;
                          });
                          _uploadImage(rootContext);
                        } else {
                          SingleMessageDialog.alert(context, "??????");
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
                                  "?????????",
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
                        final result = await _pickImage(ImageSource.gallery, context: context);
                        if (result) {
                          setState(() {
                            Navigator.of(context).pop();
                            _isUploaded = false;
                          });
                          _uploadImage(rootContext);
                        } else {
                          SingleMessageDialog.alert(context, "??????");
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
                                  "?????????",
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
                      "??????",
                      style: TextStyle(fontSize: baseWidth / 4, color: Colors.black),
                    )),
              ),
            )
          ],
        ),
      ),
    )));
  }

  Future<bool> _pickImage(ImageSource source, { bool? isRepainting, BuildContext? context }) async {
    dynamic pickedFile;
    if (isRepainting != null) {
      try {
        final orgImageURL = await FirebaseStorage.instance.ref().child('original/${_post.postId}.jpg').getDownloadURL();
        _orgImageFile = await urlToFile(orgImageURL);
      } on Exception {
        SingleMessageDialog.alert(context!, "?????? ????????? ????????? ?????? ??? ?????? ???????????????.");
        final orgImageURL = await FirebaseStorage.instance.ref().child('real/${_post.postId}.png').getDownloadURL();
        _orgImageFile = await urlToFile(orgImageURL);
      }

    } else {
      pickedFile = await picker.getImage(source: source);
      if (pickedFile != null) {
        _orgImageFile = File(pickedFile.path);
      }
    }

    if (_orgImageFile != null) {
      print("??????????????? ??????: ${_orgImageFile!.path}");
      final result = await Navigator.of(context!).push(
        MaterialPageRoute(builder: (context) => PainterWidget(backgroundImageFile: _orgImageFile!, isUpdating: true)),
      );
      if (result == null) {
        return false;
      }
      final imageFile = result['image'];
      final quality = result['quality'];
      _imageFileToUpload = imageFile;
      _thumbnailFileToUpload = await FlutterNativeImage.compressImage(
        imageFile.path,
        quality: quality,
      );
      _updateTextController.text = result['title'];
      return true;
    } else {
      return false;
    }
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = Random();
    var tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path;
    var file = File('${'$tempPath'}${rng.nextInt(100)}.jpg');
    var response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<void> _uploadImage(BuildContext rootContext) async {

    if (_imageFileToUpload != null && _thumbnailFileToUpload != null) {

      // 1. storage??? ????????? ??? ?????? ????????? ?????? ??? url ??????
      final orgImageRef = FirebaseStorage.instance.ref().child('original/${_post.postId}.jpg');
      var realImageRef = FirebaseStorage.instance.ref().child('real/${_post.postId}.png');
      var thumbImageRef = FirebaseStorage.instance.ref().child('thumbnail/${_post.postId}.png');

      final uploadTask = orgImageRef.putFile(_orgImageFile!);
      await uploadTask.whenComplete(() => print("?????? ?????? ?????? ????????? ????????? ??????"));

      final uploadTask1 = realImageRef.putFile(_imageFileToUpload!);
      final snapshot1 = await uploadTask1.whenComplete(() => print("?????? ????????? ????????? ??????"));
      final _realImgURL = await snapshot1.ref.getDownloadURL();

      final uploadTask2 = thumbImageRef.putFile(_thumbnailFileToUpload!);
      final snapshot2 = await uploadTask2.whenComplete(() => print("????????? ????????? ????????? ??????"));
      final _thumbImgURL = await snapshot2.ref.getDownloadURL();

      // 2. ?????? ????????? ??????
      final result = await CustomAPIService.updateImage(_post.postId, _thumbImgURL, _realImgURL);
      print(result);

      // 3. ?????? ?????? ??????
      FirebaseMessaging.instance.subscribeToTopic("${_post.postId}");

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
          title: Center(child: Text("????????? ?????????")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("????????? ${item.title} ???????????? ?????????????", style: TextStyle(color: Colors.red, fontSize: 20),),
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
                      child: Text("??????")),
                  ElevatedButton(
                      onPressed: () async {
                        await deleteUserImage(item, context, rootContext);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red
                      ),
                      child: Text("??????")
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
    try {
      if (result == true) {
        try {
          var orgImageRef = FirebaseStorage.instance.ref().child('original/${item.postId}.jpg');
          await orgImageRef.delete();
        } on Exception catch(e) {
          print(e);
        }

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
        SingleMessageDialog.alert(context, "?????? ??????");
      }
    } on Exception catch(e) {
      SingleMessageDialog.alert(context, "?????? ??????");
      print(e);
    }
  }

  _buildApproval(int postId, int isApproved, int isRejected) {
    var resultText = "";
    var resultBackGroundColor = Colors.yellow;
    var resultTextColor = Colors.black;
    if (isApproved == 1 && isRejected == 0) {
      FirebaseMessaging.instance.unsubscribeFromTopic("$postId");
      resultText = "?????????";
      resultTextColor = Colors.white;
      resultBackGroundColor = Colors.green;
    } else if (isApproved == 0 && isRejected == 1) {
      resultText = "?????????";
      resultTextColor = Colors.white;
      resultBackGroundColor = Colors.red;
    } else {
      resultText = "?????? ?????????";
    }

    return Container(
      decoration: BoxDecoration(
        color: resultBackGroundColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(resultText, style: TextStyle(color: resultTextColor, fontSize: 24)),
          ],
        ),
      ),
    );
  }
}