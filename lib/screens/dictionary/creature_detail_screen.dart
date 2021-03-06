import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../dto/creature/creature_detail_response.dart';
import '../../res/colors.dart';
import '../../services/server_api.dart';
import '../../widgets/app_bar_base.dart';
import '../../widgets/box_decoration.dart';
import '../../widgets/hero_dialog_route.dart';
import '../../widgets/image_dialog.dart';
import '../../widgets/loading.dart';
import '../../widgets/painter_image.dart';
import '../../widgets/single_message_dialog.dart';
import '../../widgets/user_image_card.dart';

class CreatureDetailScreen extends StatefulWidget {
  final CreatureDetailResponse _creature;
  final User? _user;

  CreatureDetailScreen(this._creature, {Key? key, User? user})
      : _user = user,
        super(key: key);

  @override
  _CreatureDetailScreenState createState() => _CreatureDetailScreenState(_creature);
}

class _CreatureDetailScreenState extends State<CreatureDetailScreen> {
  final CreatureDetailResponse _creature;
  late User? _user;
  final _dialogTextController = TextEditingController();
  final picker = ImagePicker();

  File? _imageFileToUpload;
  int _othersIndex = 0;
  final List<Widget> _othersImageCardList = [Container()];
  double _baseSize = 100;
  File? _thumbnailFileToUpload;
  int _received = -1;

  bool _isDetailLoaded = false;
  bool _isUploaded = true;
  bool _isLoading = false;

  File? _originalFile;

  _CreatureDetailScreenState(this._creature);

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    Future.delayed(Duration.zero, () {
      _buildOthersCardList(_creature.apiId, context, _user);
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    _baseSize = w > h ? h / 10 : w / 10;
    var boxRounded = w > h ? h / 30 : w / 30;

    if (!_isDetailLoaded) {
      return LoadingWidget.buildLoadingView("로딩중", _baseSize);
    } else if (!_isUploaded) {
      return LoadingWidget.buildLoadingView("업로드 중", _baseSize);
    }

    return Scaffold(
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(
          user: _user,
          image: "creature",
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
                    child: Padding(
                      padding: EdgeInsets.only(top: _baseSize / 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _user != null && !kIsWeb
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(boxRounded)), primary: Colors.blue, onSurface: Colors.blueAccent),
                                  onPressed: () {
                                    _showSelectSource(context);
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.camera,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: _baseSize / 5),
                                          child: Text(
                                            "사진 올리기",
                                            style: TextStyle(fontSize: _baseSize / 5, color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                  child: Container(
                                    height: _baseSize * 4,
                                    child: Center(
                                      child: ListView(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          _drawImage(_creature.imgUrl1, _baseSize, boxRounded),
                                          _drawImage(_creature.imgUrl2, _baseSize, boxRounded),
                                        ],
                                      ),
                                    ),
                              ))
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: _baseSize / 3, left: _baseSize / 2),
                              child: Text(
                                "${_creature.name}",
                                style: TextStyle(fontSize: _baseSize * (2 / 3), fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: _baseSize / 2, right: _baseSize / 2),
                              child: Column(
                                children: [
                                  Text(
                                    "종류: ${_creature.type}",
                                    style: TextStyle(fontSize: _baseSize / 4, fontWeight: FontWeight.w700, color: Colors.black),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: _baseSize / 3, horizontal: _baseSize / 2),
                          child: Container(
                            height: 2,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: _baseSize / 3, left: _baseSize / 2, right: _baseSize / 2),
                          child: Html(
                            data: _creature.detail,
                            style: {
                              "html": Style(color: Colors.black, fontSize: FontSize(_baseSize / 3)),
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: _baseSize / 10, left: _baseSize / 2, right: _baseSize / 2),
                          child: Text(
                            "출처 | 산림청 국립수목원 국가생물종지식정보시스템 어린이생물도감\n본 콘텐츠의 저작권은 제공처에 있으며, 해당 자료의 무단복제 및 배포를 금합니다.\n외부 콘텐츠는 웅진씽크빅의 입장과 다를 수 있습니다.",
                            style: TextStyle(color: Colors.grey, fontSize: _baseSize / 5),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Container(
                            decoration: BoxDecoration(color: Color(0xF3FFEE98), borderRadius: BorderRadius.all(Radius.circular(28))),
                            child: Column(
                              children: [
                                _othersImageCardList.length == 1
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(vertical: _baseSize / 4),
                                        child: Text(
                                          "아직 관련 사진을 찍은 친구가 없어요!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black, fontSize: _baseSize * (1 / 3)),
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(vertical: _baseSize / 4),
                                        child: Text(
                                          "친구들이 찍은 사진",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black, fontSize: _baseSize * (2 / 3)),
                                        ),
                                      ),
                                _othersImageCardList.length == 1
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsets.all(_baseSize / 4),
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          children: [
                                            Expanded(
                                                child: Container(
                                                    height: 400,
                                                    child: NotificationListener<ScrollEndNotification>(
                                                      onNotification: (scrollEnd) {
                                                        final metrics = scrollEnd.metrics;
                                                        if (metrics.atEdge) {
                                                          if (metrics.pixels != 0) {
                                                            if (_received == -1 || _received == 5) {
                                                              setState(() {
                                                                _isLoading = true;
                                                              });
                                                              _othersIndex++;
                                                              _buildOthersCardList(_creature.apiId, context, _user);
                                                            }
                                                          }
                                                        }
                                                        return true;
                                                      },
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: _othersImageCardList.length + 1,
                                                        itemBuilder: (context, index) {
                                                          if (index == _othersImageCardList.length) {
                                                            return _isLoading
                                                                ? Container(
                                                                    child: Center(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          CircularProgressIndicator(
                                                                            color: Colors.red,
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.all(_baseSize / 10),
                                                                            child: Text(
                                                                              "로딩중",
                                                                              style: TextStyle(color: Colors.red, fontSize: _baseSize / 2),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container();
                                                          }
                                                          return _othersImageCardList[index];
                                                        },
                                                      ),
                                                    )))
                                          ],
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ),
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
        :
    Material(
      color: CustomColors.white,
      child: InkWell(
        onTap: () {
          ImageDialog.show(context, imageUrl);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: baseSize / 3),
          child: Container(
            child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    height: baseSize * 8,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: CustomColors.creatureGreen,),
                              SizedBox(height: _baseSize/2,),
                              Text(
                                "로딩중",
                                style: TextStyle(color: CustomColors.creatureGreen, fontSize: _baseSize / 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
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
    Navigator.of(context).push(HeroDialogRoute(
        builder: (context) => Center(
              child: AlertDialog(
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
                                  final result = await _pickImage(ImageSource.camera);
                                  if (result) {
                                    _showTitleDialog(context, rootContext);
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
                                    _showTitleDialog(context, rootContext);
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
              ),
            )));
  }

  Future<bool> _pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      _originalFile = File(pickedFile.path);
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PainterWidget(backgroundImageFile: _originalFile!)),
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
      _dialogTextController.text = result['title'];
      return true;
    } else {
      return false;
    }
  }

  _showTitleDialog(BuildContext parentContext, BuildContext rootContext) {
    Navigator.of(context).push(HeroDialogRoute(builder: (context) {
      var w = MediaQuery.of(context).size.width / 10;
      var h = MediaQuery.of(context).size.height / 10;
      return Center(
        child: AlertDialog(
          title: Text('촬영한 사진의 제목을 입력해 주세요!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _dialogTextController,
                decoration: InputDecoration(
                  floatingLabelBehavior:FloatingLabelBehavior.never,
                  border: UnderlineInputBorder(),
                  labelText: '8자 이내로 입력',
                  labelStyle: TextStyle(color: Colors.black45),
                  fillColor: Colors.black,),
                style: TextStyle(color: Colors.black, fontSize: 20),
                onSubmitted: (text) async {
                  if (text.length <= 8) {
                    setState(() {
                      Navigator.pop(context);
                      Navigator.pop(parentContext);
                      _isUploaded = false;
                    });
                    await _uploadImage(rootContext, _dialogTextController.text);
                  } else {
                    SingleMessageDialog.alert(context, "제목을 8자 이내로 입력해주세요");
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(h / 8),
                    child: Container(
                      height: h * (2 / 3),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                          child: Text(
                            "닫기",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: w / 4, color: Colors.black),
                          )),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(h / 8),
                    child: Container(
                      height: h * (2 / 3),
                      child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              Navigator.pop(context);
                              Navigator.pop(parentContext);
                              FocusScope.of(context).unfocus();
                              _isUploaded = false;
                            });
                            await _uploadImage(rootContext, _dialogTextController.text);
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.white, onSurface: Colors.white70, side: BorderSide(style: BorderStyle.none, width: 2.0, color: Colors.black)),
                          child: Text(
                            "업로드",
                            style: TextStyle(fontSize: w / 4, color: Colors.black),
                          )),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );
    }));
  }

  Future<void> _uploadImage(BuildContext rootContext, String title) async {
    if (_imageFileToUpload != null && _thumbnailFileToUpload != null) {
      // 1. 이미지 없이 등록 후 postId 받아서
      var postId = await CustomAPIService.registerPost("C${_creature.apiId}", title);

      // 2. storage에 썸네일 및 원본 이미지 저장 후 url 추출
      var orgImageRef = FirebaseStorage.instance.ref().child('original/$postId.jpg');
      var realImageRef = FirebaseStorage.instance.ref().child('real/$postId.png');
      var thumbImageRef = FirebaseStorage.instance.ref().child('thumbnail/$postId.png');

      final uploadTask = orgImageRef.putFile(_originalFile!);
      await uploadTask.whenComplete(() => print("그림 없는 원본 이미지 업로드 완료"));

      final uploadTask1 = realImageRef.putFile(_imageFileToUpload!);
      final snapshot1 = await uploadTask1.whenComplete(() => print("원본 이미지 업로드 완료"));
      final _realImgURL = await snapshot1.ref.getDownloadURL();

      final uploadTask2 = thumbImageRef.putFile(_thumbnailFileToUpload!);
      final snapshot2 = await uploadTask2.whenComplete(() => print("썸네일 이미지 업로드 완료"));
      final _thumbImgURL = await snapshot2.ref.getDownloadURL();

      // 3. 다시 이미지 등록
      final result = await CustomAPIService.updateImage(postId, _thumbImgURL, _realImgURL);
      print(result);

      // 4. 푸시 알림 등록
      FirebaseMessaging.instance.subscribeToTopic("$postId");

      setState(() {
        _isUploaded = true;
      });
    }
  }

  _buildOthersCardList(String apiId, BuildContext context, User? user) async {
    final firstTime = DateTime.now(); // 2초 딜레이 재기

    final posts = await CustomAPIService.getOthersPostBy("C$apiId", _othersIndex);
    _received = posts.length;
    final resultList = UserImageCard.buildImageCard(posts, context, user);
    _othersImageCardList.addAll(resultList);

    final passedTime = firstTime.difference(DateTime.now());
    if (passedTime < Duration(seconds: 2)) {
      await Future.delayed(Duration(seconds: 2) - passedTime);
    }

    setState(() {
      _isDetailLoaded = true;
      if (_received == 0) {
        _isLoading = false;
      }
    });
  }
}
