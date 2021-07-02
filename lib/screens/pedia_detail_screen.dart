import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

import '../dto/dict/dict_detail_response.dart';
import '../dto/dict/dict_response.dart';
import '../dto/photos/photo_response.dart';
import '../res/colors.dart';
import '../services/server_api.dart';
import '../services/woongjin_api.dart';
import '../widgets/app_bar_base.dart';
import '../widgets/box_decoration.dart';
import '../widgets/hero_dialog_route.dart';
import '../widgets/image_dialog.dart';
import '../widgets/loading.dart';
import '../widgets/user_image_card.dart';

class PediaDetailScreen extends StatefulWidget {
  final DictResponse _pedia;
  final User _user;

  PediaDetailScreen(this._pedia, {Key? key, required User user})
      : _user = user,
        super(key: key);

  @override
  _PediaDetailState createState() => _PediaDetailState(_pedia);
}

class _PediaDetailState extends State<PediaDetailScreen> {
  final DictResponse _pedia;
  late DictDetailResponse _pediaDetail;
  late User _user;
  late List<PhotoResponse> _subImageList;
  double _baseSize = 100;
  bool _isDetailLoaded = false;
  bool _isUploaded = true;

  final picker = ImagePicker();
  final List<Widget> _othersImageCardList = [Container()];

  File? _imageFileToUpload;
  File? _thumbnailFileToUpload;

  int _received = -1;
  int _othersIndex = 0;
  bool _isLoading = false;

  _PediaDetailState(this._pedia);

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    _loadPediaDetail();
    Future.delayed(Duration.zero,() {
      _buildOthersCardList(context);
    });
  }

  _loadPediaDetail() async {
    _pediaDetail = await WoongJinAPIService.searchDetailWJPedia(_pedia.apiId);
    _subImageList = await WoongJinAPIService.searchPhotoLibrary(_pedia.name);
    _isDetailLoaded = true;
    setState(() {});
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
      return LoadingWidget.buildLoadingView("업로드중", _baseSize);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(user: _user, image: "creature"),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: _baseSize / 10),
                                child: Icon(Icons.assistant_navigation),
                              ),
                              Text(
                                _pediaDetail.category1,
                                style: TextStyle(color: Colors.black, fontSize: _baseSize / 3),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: _baseSize / 10),
                                child: Icon(Icons.arrow_forward_ios_rounded),
                              ),
                              Text(
                                _pediaDetail.category2,
                                style: TextStyle(color: Colors.black, fontSize: _baseSize / 3),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: _baseSize / 10),
                                child: Icon(Icons.arrow_forward_ios_rounded),
                              ),
                              Text(
                                _pediaDetail.category3,
                                style: TextStyle(color: Colors.black, fontSize: _baseSize / 3),
                              ),
                            ],
                          ),
                          ElevatedButton(
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
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: ListView(
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                              child: Container(
                            height: 400,
                            child: Center(
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: _buildImages(_baseSize, boxRounded),
                              ),
                            ),
                          ))
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: _baseSize / 6, left: _baseSize / 2),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _pedia.name,
                                style: TextStyle(fontSize: _baseSize * (2 / 3), fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: _baseSize / 10),
                                child: Text(
                                  "(${_pedia.subName})",
                                  style: TextStyle(fontSize: _baseSize * (1 / 3), color: Colors.black),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: _baseSize / 10, left: _baseSize / 2, right: _baseSize / 2),
                        child: Html(
                          data: _pediaDetail.detail,
                          style: {
                            "html": Style(color: Colors.black, fontSize: FontSize(_baseSize/3)),
                            "a": Style(color: Colors.black),
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: _baseSize / 10, left: _baseSize / 2, right: _baseSize / 2),
                        child: Text(
                          "출처 | 웅진학습백과\n본 콘텐츠는 학교 공부나 숙제, 웅진씽크빅의 다른 콘텐츠에 이용할 수 있습니다.\n단, 영리 목적이 아닌 개인적인 용도로만 이용할 수 있습니다.\n본 콘텐츠의 글 저작권과 편집저작물 저작권은 웅진씽크빅에 있으며, 시청각 자료의 저작권은 웅진씽크빅이나 저작자나 제공처에 있습니다.",
                          style: TextStyle(color: Colors.grey, fontSize: _baseSize/5),
                        ),
                      ),
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
                              padding: EdgeInsets.symmetric(vertical: _baseSize / 3),
                              child: Text(
                                "친구들이 찍은 사진",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black, fontSize: _baseSize * (2 / 3)),
                              ),
                            ),
                      _othersImageCardList.length == 1
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: _baseSize / 4),
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
                                                    _buildOthersCardList(context);
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
                                                  return _isLoading ? Container(
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
                                                return _othersImageCardList[index];
                                              },
                                            ),
                                          )))
                                ],
                              ),
                            )
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildImages(double baseSize, double boxRounded) {
    final imageUrlList = _pedia.imageURLs;
    final resultList = <Widget>[];
    for (var url in imageUrlList) {
      resultList.add(Material(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            ImageDialog.showFullImageDialog(context, url);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: baseSize / 8),
            child: Container(
              child: Center(
                  child: Image.network(
                    url,
                    height: baseSize * 8,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: _baseSize/2),),),);
                    },
                  )
              ),
            ),
          ),
        ),
      ));
    }
    for (var subItem in _subImageList) {
      resultList.add(Material(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            ImageDialog.showFullImageDialog(context, subItem.imgURL);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: baseSize / 8),
            child: Center(
              child: Image.network(
                subItem.imgURL,
                height: baseSize * 8,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: _baseSize/2),),),);
                },
              ),
            ),
          ),
        ),
      ));
    }
    return resultList;
  }

  _buildOthersCardList(BuildContext context) async {
    final posts = await CustomAPIService.getOthersPostBy("P${_pedia.apiId}", _othersIndex);
    _received = posts.length;
    var resultList = UserImageCard.buildImageCard(posts, context, _user);
    setState(() {
      _othersImageCardList.addAll(resultList);
      if (_received == 0) {
        _isLoading = false;
      }
    });
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
                          final result = await _pickImage(ImageSource.gallery);
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
      ),
    )));
  }
  Future<bool> _pickImage(ImageSource source) async {
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
    final dialogTextController = TextEditingController();
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
                controller: dialogTextController,
                decoration: InputDecoration(hintText: "사진 이름"),
                onSubmitted: (text) async {
                  setState(() {
                    Navigator.pop(context);
                    Navigator.pop(parentContext);
                    _isUploaded = false;
                  });
                  await _uploadImage(rootContext, dialogTextController.text);
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
                            await _uploadImage(rootContext, dialogTextController.text);
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
    ); }));
  }
  Future<void> _uploadImage(BuildContext rootContext, String title) async {
    if (_imageFileToUpload != null && _thumbnailFileToUpload != null) {
      // 1. 이미지 없이 등록 후 postId 받아서
      var postId = await CustomAPIService.registerPost("P${_pedia.apiId}", title);

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
      print(result);

      setState(() {
        _isUploaded = true;
      });
    }
    Navigator.of(rootContext).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PediaDetailScreen(
          _pedia,
          user: _user,
        ),
      ),
    );
  }
}
