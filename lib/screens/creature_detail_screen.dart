import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

import '../dto/creature/creature_detail_response.dart';
import '../dto/post/post_response.dart';
import '../res/colors.dart';
import '../services/server_api.dart';
import '../widgets/app_bar_base.dart';

class CreatureDetailScreen extends StatefulWidget {
  final CreatureDetailResponse _creature;
  final User _user;

  CreatureDetailScreen(this._creature, {Key? key, required User user}): _user = user,
        super(key: key);

  @override
  _CreatureDetailScreenState createState() => _CreatureDetailScreenState(_creature);
}

class _CreatureDetailScreenState extends State<CreatureDetailScreen> {
  final CreatureDetailResponse _creature;
  late User _user;
  final _dialogTextController = TextEditingController();
  final picker = ImagePicker();

  File? _imageFileToUpload;
  int _othersIndex = 0;
  final List<Widget> _othersImageCardList = [Container()];
  double baseSize = 100;
  File? _thumbnailFileToUpload;
  int received = -1;

  _CreatureDetailScreenState(this._creature);

  @override
  void initState() {
    _user = widget._user;
    _buildOthersCardList(_creature.apiId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    baseSize = w > h ? h / 10 : w / 10;
    var boxRounded = w > h ? h / 30 : w / 30;

    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(user: _user,),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(baseSize / 2),
          child: Center(
            child: Container(
              width: w * (9 / 10),
              height: h * (9 / 10),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: Colors.white30), borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                BoxShadow(
                  color: Colors.white10,
                  offset: Offset(4.0, 4.0),
                  blurRadius: 15.0,
                  spreadRadius: 1.0,
                )
              ]),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Container(
                    width: w * (9 / 10),
                    child: Padding(
                      padding: EdgeInsets.all(baseSize / 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigator.of(context).pushReplacement(ScreenAnimation.routeTo(SearchCreatureScreen(user: _user)));
                              },
                              icon: Icon(CupertinoIcons.back, color: Colors.black, size: baseSize/2,)),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(boxRounded)), primary: Colors.blue, onSurface: Colors.blueAccent),
                              onPressed: () {
                                _showSelectSource(context);
                                // _showTitleDialog(context);
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.camera,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: baseSize / 5),
                                      child: Text(
                                        "사진 올리기",
                                        style: TextStyle(fontSize: baseSize / 5, color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _drawImage(_creature.imgUrl1, baseSize, boxRounded),
                            _drawImage(_creature.imgUrl2, baseSize, boxRounded),
                            _drawImage(_creature.imgUrl3, baseSize, boxRounded),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: baseSize / 2, left: baseSize / 2),
                              child: Text(
                                "${_creature.name}",
                                style: TextStyle(fontSize: baseSize * (2 / 3), fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: baseSize / 2, right: baseSize / 2),
                              child: Column(
                                children: [
                                  Text(
                                    "종류: ${_creature.type}",
                                    style: TextStyle(fontSize: baseSize / 4, fontWeight: FontWeight.w700, color: Colors.black),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: baseSize / 3, horizontal: baseSize / 2),
                          child: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: baseSize / 3, left: baseSize / 2, right: baseSize / 2),
                          child: Html(
                            data: _creature.detail,
                            style: {
                              "html": Style(color: Colors.black),
                            },
                          ),
                        ),
                        _othersImageCardList.length == 1 ? Padding(
                          padding: EdgeInsets.symmetric(vertical: baseSize / 4),
                          child: Text(
                            "아직 관련 생물을 찍은 친구가 없어요!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: baseSize * (1 / 3)),
                          ),
                        ) : Padding(
                          padding: EdgeInsets.symmetric(vertical: baseSize / 3),
                          child: Text(
                            "친구들이 찍은 사진",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: baseSize * (2 / 3)),
                          ),
                        ),
                        _othersImageCardList.length == 1 ? Container() : Padding(
                          padding: EdgeInsets.symmetric(horizontal: baseSize / 4),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 350,
                                  child: NotificationListener<ScrollEndNotification> (
                                    onNotification: (scrollEnd) {
                                      var metrics = scrollEnd.metrics;
                                      if (metrics.atEdge) {
                                        if (metrics.pixels != 0) {
                                          print('page: $_othersIndex, received: $received');
                                          if (received == -1 || received == 5) {
                                            _othersIndex++;
                                            _buildOthersCardList(_creature.apiId);
                                          }
                                        }
                                      }
                                      return true;
                                    },
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _othersImageCardList.length,
                                      itemBuilder: (context, index) {
                                        return _othersImageCardList[index];
                                      },
                                    ),
                                  )
                              ))
                            ],
                          ),
                        )
                      ],
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

  Widget _drawImage(String imageUrl, double baseSize, double boxRounded) {
    return imageUrl == 'NONE'
        ? Padding(
            padding: EdgeInsets.all(baseSize / 4),
            child: Container(child: null),
          )
        : Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                _showFullImageDialog(context, imageUrl);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: baseSize / 3),
                child: Container(
                  width: baseSize * 4,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(boxRounded)), border: Border.all(color: Colors.black, width: 2.0)),
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Center(
                        child: Image.network(
                      imageUrl,
                      height: baseSize * 3,
                    )),
                  ),
                ),
              ),
            ),
          );
  }

  _showSelectSource(BuildContext rootContext) {
    var w = MediaQuery.of(rootContext).size.width;
    var h = MediaQuery.of(rootContext).size.height;

    var baseSize = w > h ? h / 10 : w / 10;
    var baseWidth = w / 10;
    var baseHeight = h / 10;
    var boxRounded = w > h ? h / 30 : w / 30;
    return showDialog(
        context: rootContext,
        builder: (context) {
          return AlertDialog(
            title: Text(
              '사진을 촬영하거나 가져오기',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
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
                              final result = await pickImage(ImageSource.camera);
                              if (result) {
                                _showTitleDialog(context, rootContext);
                              } else {
                                print("실패");
                              }
                              // TODO 실패 시 알려주기
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
                              final result = await pickImage(ImageSource.gallery);
                              if (result) {
                                _showTitleDialog(context, rootContext);
                              } else {
                                print("실패");
                              }
                              // TODO 실패 시 알려주기
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
          );
        });
  }

  Future<bool> pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      _imageFileToUpload = File(pickedFile.path);
      _thumbnailFileToUpload = await FlutterNativeImage.compressImage(
        pickedFile.path,
        quality: 5,
      );
      return true;
    } else {
      return false;
    }
  }

  _showTitleDialog(BuildContext parentContext, BuildContext rootContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          var w = MediaQuery.of(context).size.width / 10;
          var h = MediaQuery.of(context).size.height / 10;

          return AlertDialog(
            title: Text('촬영한 사진의 제목을 입력해 주세요!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  controller: _dialogTextController,
                  decoration: InputDecoration(hintText: "사진 이름"),
                  onSubmitted: (text) async {
                    await _uploadImage(rootContext, context, parentContext, _dialogTextController.text);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(h / 8),
                      child: Container(
                        width: w * (2 / 3),
                        height: h * (2 / 3),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                            child: Text(
                              "닫기",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: w / 8, color: Colors.black),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(h / 8),
                      child: Container(
                        width: w * (2 / 3),
                        height: h * (2 / 3),
                        child: ElevatedButton(
                            onPressed: () async {
                              await _uploadImage(rootContext, context, parentContext, _dialogTextController.text);
                            },
                            style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                            child: Text(
                              "업로드",
                              style: TextStyle(fontSize: w / 8, color: Colors.black),
                            )),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<void> _uploadImage(BuildContext rootContext, BuildContext context, BuildContext parentContext, String title) async {
    if (_imageFileToUpload != null && _thumbnailFileToUpload != null) {
      // 1. 이미지 없이 등록 후 postId 받아서
      var postId = await CustomAPIService.registerPost(_creature.apiId, title);

      // 2. storage에 썸네일 및 원본 이미지 저장 후 url 추출
      var realImageRef = FirebaseStorage.instance.ref().child('real/$postId.png');
      var thumbImageRef = FirebaseStorage.instance.ref().child('thumbnail/$postId.png');

      final uploadTask1 = realImageRef.putFile(_imageFileToUpload!);
      final snapshot1 = await uploadTask1.whenComplete(() => print("원본 이미지 업로드 완료"));
      final _realImgURL = await snapshot1.ref.getDownloadURL();

      final uploadTask2 = thumbImageRef.putFile(_thumbnailFileToUpload!);
      final snapshot2 = await uploadTask2.whenComplete(() => print("썸네일 이미지 업로드 완료"));
      final _thumbImgURL = await snapshot2.ref.getDownloadURL();

      // 3. 다시 이미지 등록
      final result = await CustomAPIService.updateImage(postId, _thumbImgURL, _realImgURL);
      if (result) {
        ScaffoldMessenger.of(rootContext).showSnackBar(customSnackBar(content: '업로드 완료!'));
      } else {
        ScaffoldMessenger.of(rootContext).showSnackBar(customSnackBar(content: '업로드 실패!'));
      }
    }
    Navigator.pop(context);
    Navigator.pop(parentContext);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CreatureDetailScreen(_creature, user: _user,),
      ),
    );
  }

  _showFullImageDialog(BuildContext parentContext, String imageURL) {
    return showDialog(
        context: context,
        builder: (context) {
          var baseWidth = MediaQuery.of(parentContext).size.width / 10;
          var baseHeight = MediaQuery.of(parentContext).size.height / 10;
          return AlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InteractiveViewer(
                  panEnabled: false,
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageURL,
                    height: baseHeight * 5,
                  ),
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
          );
        });
  }

  _buildOthersCardList(int apiId) async {
    final result = await CustomAPIService.getOthersPostBy(apiId, _othersIndex);
    final posts = result['posts'] as List<PostResponse>;
    received = posts.length;
    var resultList = <Widget>[];
    for (var item in posts) {
      final widget = Padding(
        padding: EdgeInsets.all(baseSize / 4),
        child: Container(
          width: 300,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(baseSize / 2)), border: Border.all(color: Colors.black, width: 2.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(baseSize / 8),
                child: Image.network(
                  item.tbImgURL,
                  width: 200,
                  height: 150,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: baseSize / 4),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: Colors.black, fontSize: baseSize / 3),
                    ),
                    Text(
                      item.nickname!,
                      style: TextStyle(color: Colors.black, fontSize: baseSize / 4),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.red,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: baseSize / 8),
                                  child: Text(
                                    item.likes.toString(),
                                    style: TextStyle(color: Colors.red, fontSize: baseSize / 4),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                    CupertinoIcons.eye,
                                    color: Colors.black
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: baseSize / 8),
                                  child: Text(
                                    item.views.toString(),
                                    style: TextStyle(color: Colors.black, fontSize: baseSize / 4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: baseSize/10),
                          child: ElevatedButton(
                              onPressed: () {

                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  onSurface: Colors.white70,
                                  side: BorderSide(color: Colors.black, width: 2.0),
                                  shadowColor: Colors.white10
                              ),
                              child: Text("상세보기", style: TextStyle(color: Colors.black, fontSize: baseSize/5),)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      resultList.add(widget);
    }
    setState(() {
      _othersImageCardList.addAll(resultList);
    });
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.yellowAccent, letterSpacing: 0.5),
      ),
    );
  }
}
