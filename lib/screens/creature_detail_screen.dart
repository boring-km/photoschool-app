import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photoschool/domain/post_response.dart';
import 'package:photoschool/domain/searched_detail_item.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/services/server_api.dart';
import 'package:photoschool/widgets/app_bar_base.dart';

class CreatureDetailScreen extends StatefulWidget {
  final SearchedDetailItem _creature;

  CreatureDetailScreen(this._creature);

  @override
  _CreatureDetailScreenState createState() =>
      _CreatureDetailScreenState(_creature);
}

class _CreatureDetailScreenState extends State<CreatureDetailScreen> {
  final SearchedDetailItem _creature;
  var _dialogTextController = TextEditingController();
  final picker = ImagePicker();

  File? _imageFileToUpload;
  int _othersIndex = 0;
  int numOfPosts = 0;
  List<Widget> _othersImageCardList = [];
  double baseSize = 100;
  _CreatureDetailScreenState(this._creature);

  @override
  void initState() {
    _buildOthersCardList(_creature.apiId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    baseSize = w > h ? h / 10 : w / 10;
    double boxRounded = w > h ? h / 30 : w / 30;

    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(baseSize / 2),
          child: Center(
            child: Container(
              width: w * (9 / 10),
              height: h * (9 / 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.white30),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(boxRounded)),
                                  primary: Colors.blue,
                                  onSurface: Colors.blueAccent),
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
                                      padding:
                                          EdgeInsets.only(left: baseSize / 5),
                                      child: Text(
                                        "사진 올리기",
                                        style: TextStyle(
                                            fontSize: baseSize / 5,
                                            color: Colors.white),
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
                              padding: EdgeInsets.only(
                                  top: baseSize / 2, left: baseSize / 2),
                              child: Text(
                                "${_creature.name}",
                                style: TextStyle(
                                    fontSize: baseSize * (2 / 3),
                                    color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: baseSize / 2, right: baseSize / 2),
                              child: Column(
                                children: [
                                  Text(
                                    "종류: ${_creature.type}",
                                    style: TextStyle(
                                        fontSize: baseSize / 4,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: baseSize / 3, horizontal: baseSize / 2),
                          child: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: baseSize / 3,
                              left: baseSize / 2,
                              right: baseSize / 2),
                          child: Html(
                            data: _creature.detail,
                            style: {
                              "html": Style(color: Colors.black),
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: baseSize / 3),
                          child: Text(
                            "다른 친구들이 찍은 사진",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: baseSize * (2 / 3)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: baseSize / 4),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 400,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: _othersImageCardList,
                                  ),
                                )
                              )
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
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.all(Radius.circular(boxRounded)),
                      border: Border.all(color: Colors.black, width: 2.0)),
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

  _showSelectSource(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    double baseSize = w > h ? h / 10 : w / 10;
    double baseWidth = w / 10;
    double baseHeight = h / 10;
    double boxRounded = w > h ? h / 30 : w / 30;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(boxRounded)),
                              primary: Colors.white,
                              onSurface: Colors.white30),
                          onPressed: () async {
                            final result = await pickImage(ImageSource.camera);
                            if (result)
                              _showTitleDialog(context);
                            else
                              print("실패");
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
                                      style: TextStyle(
                                          fontSize: baseSize / 4,
                                          color: Colors.black),
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
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(boxRounded)),
                              primary: Colors.white,
                              onSurface: Colors.white30),
                          onPressed: () async {
                            final result = await pickImage(ImageSource.gallery);
                            if (result)
                              _showTitleDialog(context);
                            else
                              print("실패");
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
                                      style: TextStyle(
                                          fontSize: baseSize / 4,
                                          color: Colors.black),
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
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onSurface: Colors.white70,
                            side: BorderSide(
                                style: BorderStyle.none,
                                width: 2.0,
                                color: Colors.black)),
                        child: Text(
                          "닫기",
                          style: TextStyle(
                              fontSize: baseWidth / 4, color: Colors.black),
                        )
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<bool> pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      _imageFileToUpload = File(pickedFile.path);
      return true;
    } else
      return false;
  }

  _showTitleDialog(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            title: Text('촬영한 사진의 제목을 입력해 주세요!'),
            content: TextField(
              controller: _dialogTextController,
              decoration: InputDecoration(hintText: "당신 닮은 푸른 소나무~"),
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('취소'),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  /* TODO
                      1. 이미지 없이 등록 후 postId 받아서
                      2. storage에 썸네일 및 원본 이미지 저장 후 url 추출
                      3. 다시 이미지 등록 */
                  Navigator.pop(context);
                  Navigator.pop(parentContext);
                },
                child: Text('업로드'),
              )
            ],
          );
        });
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
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onSurface: Colors.white70,
                            side: BorderSide(
                                style: BorderStyle.none,
                                width: 2.0,
                                color: Colors.black)),
                        child: Text(
                          "닫기",
                          style: TextStyle(
                              fontSize: baseWidth / 4, color: Colors.black),
                        )
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  _buildOthersCardList(int apiId) async {
    final result = await CustomAPIService.getOthersPostBy(apiId, _othersIndex);
    numOfPosts = result['numOfPosts'] as int;
    final List<PostResponse> posts = result['posts'] as List<PostResponse>;

    List<Widget> resultList = [];
    for (var item in posts) {
      final widget = Padding(
        padding: EdgeInsets.all(baseSize / 4),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(baseSize/2)),
              border: Border.all(color: Colors.black, width: 2.0)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(baseSize/8),
                child: Image.network(item.tbImgURL, width: 200,),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: baseSize/4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Column(
                      children: [
                        Text(item.title, style: TextStyle(color: Colors.black, fontSize: baseSize/3),),
                        Text(item.nickname!, style: TextStyle(color: Colors.black, fontSize: baseSize/4),),
                      ],
                    ),
                    Column(
                      children: [
                        Text(item.likes.toString(), style: TextStyle(color: Colors.red, fontSize: baseSize/4),),
                        Text(item.views.toString(), style: TextStyle(color: Colors.black, fontSize: baseSize/4),),
                      ],
                    )
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
      _othersImageCardList = resultList;
    });
  }
}
