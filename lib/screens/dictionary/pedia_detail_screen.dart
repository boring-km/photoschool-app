import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../dto/dict/dict_detail_response.dart';
import '../../dto/dict/dict_response.dart';
import '../../dto/photos/photo_response.dart';
import '../../res/colors.dart';
import '../../services/server_api.dart';
import '../../services/woongjin_api.dart';
import '../../widgets/app_bar_base.dart';
import '../../widgets/box_decoration.dart';
import '../../widgets/hero_dialog_route.dart';
import '../../widgets/image_dialog.dart';
import '../../widgets/loading.dart';
import '../../widgets/painter_image.dart';
import '../../widgets/single_message_dialog.dart';
import '../../widgets/user_image_card.dart';

class PediaDetailScreen extends StatefulWidget {
  final DictResponse _pedia;
  final User? _user;

  PediaDetailScreen(this._pedia, {Key? key, User? user})
      : _user = user,
        super(key: key);

  @override
  _PediaDetailState createState() => _PediaDetailState(_pedia);
}

class _PediaDetailState extends State<PediaDetailScreen> {
  final DictResponse _pedia;
  late DictDetailResponse _pediaDetail;
  late User? _user;
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

  final _scrollController = ScrollController();
  final _dialogTextController = TextEditingController();

  File? _originalFile;

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
    final firstTime = DateTime.now(); // 2??? ????????? ??????
    _pediaDetail = await WoongJinAPIService.searchDetailWJPedia(_pedia.apiId);
    _subImageList = await WoongJinAPIService.searchPhotoLibrary(_pedia.name, _pediaDetail.categoryNo);
    final passedTime = firstTime.difference(DateTime.now());
    if (passedTime < Duration(seconds: 2)) {
      await Future.delayed(Duration(seconds: 2) - passedTime);
    }
    setState(() {
      _isDetailLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    _baseSize = w > h ? h / 10 : w / 10;
    var boxRounded = w > h ? h / 30 : w / 30;

    if (!_isDetailLoaded) {
      return LoadingWidget.buildLoadingView("?????????", _baseSize);
    } else if (!_isUploaded) {
      return LoadingWidget.buildLoadingView("????????? ???", _baseSize);
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _user != null && !kIsWeb ? Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(boxRounded)), primary: Colors.orange, onSurface: Colors.orangeAccent),
                                    onPressed: () {
                                      _sendEmail(_pediaDetail, _user!);
                                    },
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Icon(Icons.email_outlined, color: Colors.white,),
                                          Padding(
                                            padding: EdgeInsets.only(left: _baseSize / 5),
                                            child: Text(
                                              "????????? ?????????",
                                              style: TextStyle(fontSize: _baseSize / 5, color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                ),
                              ) : Container(),
                              _user != null && !kIsWeb ? ElevatedButton(
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
                                            "?????? ?????????",
                                            style: TextStyle(fontSize: _baseSize / 5, color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ) : Container()
                            ],
                          ),
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
                                  ))],
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
                              "?????? | ??????????????????\n??? ???????????? ?????? ????????? ??????, ?????????????????? ?????? ???????????? ????????? ??? ????????????.\n???, ?????? ????????? ?????? ???????????? ???????????? ????????? ??? ????????????.\n??? ???????????? ??? ???????????? ??????????????? ???????????? ?????????????????? ?????????, ????????? ????????? ???????????? ????????????????????? ???????????? ???????????? ????????????.",
                              style: TextStyle(color: Colors.grey, fontSize: _baseSize/5),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xF3FFEE98),
                                  borderRadius: BorderRadius.all(Radius.circular(28))
                              ),
                              child: Column(
                                children: [
                                  _othersImageCardList.length == 1
                                      ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: _baseSize / 4),
                                    child: Text(
                                      "?????? ?????? ????????? ?????? ????????? ?????????!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black, fontSize: _baseSize * (1 / 3)),
                                    ),
                                  )
                                      : Padding(
                                    padding: EdgeInsets.symmetric(vertical: _baseSize / 3),
                                    child: Text(
                                      "???????????? ?????? ??????",
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
                                                                  child: Text("?????????", style: TextStyle(color: Colors.red, fontSize: _baseSize/2),),
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
                              ),
                            ),
                          ),
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
        color: CustomColors.white,
        child: InkWell(
          onTap: () {
            ImageDialog.show(context, url);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: baseSize / 8),
            child: Container(
              child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      url,
                      height: baseSize * 5,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: CustomColors.orange,),
                                SizedBox(height: _baseSize/2,),
                                Text(
                                  "?????????",
                                  style: TextStyle(color: CustomColors.orange, fontSize: _baseSize / 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
              ),
            ),
          ),
        ),
      ));
    }
    imageUrlList.isNotEmpty ? resultList.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 2,
          height: baseSize * 4,
          color: Colors.black,
        ),
      )
    ) : null;
    for (var subItem in _subImageList) {
      resultList.add(Material(
        color: CustomColors.white,
        child: InkWell(
          onTap: () async {
            await ImageDialog.showWithWJDict(context, subItem.imgURL, subItem.apiId);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: baseSize / 8),
            child: Container(
              child: Container(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      subItem.imgURL,
                      height: baseSize * (4.5),
                      fit: BoxFit.fitHeight,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(child: Center(child: Text("?????????", style: TextStyle(color: CustomColors.orange, fontSize: baseSize/2),),),);
                      },
                    ),
                  ),
                ),
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
    final resultList = UserImageCard.buildImageCard(posts, context, _user);
    _othersImageCardList.addAll(resultList);
    setState(() {
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
          '????????? ??????????????? ????????????',
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
                          final result = await _pickImage(ImageSource.gallery);
                          if (result) {
                            _showTitleDialog(context, rootContext);
                          } else {
                            print("??????");
                          }
                          // TODO ?????? ??? ????????????
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
      ),
    )));
  }
  Future<bool> _pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      _originalFile = File(pickedFile.path);
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PainterWidget(backgroundImageFile: _originalFile!,)),
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
          title: Text('????????? ????????? ????????? ????????? ?????????!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _dialogTextController,
                decoration: InputDecoration(
                  floatingLabelBehavior:FloatingLabelBehavior.never,
                  border: UnderlineInputBorder(),
                  labelText: '8??? ????????? ??????',
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
                    SingleMessageDialog.alert(context, "????????? 8??? ????????? ??????????????????");
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
                            "??????",
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
                            "?????????",
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
      // 1. ????????? ?????? ?????? ??? postId ?????????
      var postId = await CustomAPIService.registerPost("P${_pedia.apiId}", title);

      // 2. storage??? ????????? ??? ?????? ????????? ?????? ??? url ??????
      var orgImageRef = FirebaseStorage.instance.ref().child('original/$postId.jpg');
      var realImageRef = FirebaseStorage.instance.ref().child('real/$postId.png');
      var thumbImageRef = FirebaseStorage.instance.ref().child('thumbnail/$postId.png');

      final uploadTask = orgImageRef.putFile(_originalFile!);
      await uploadTask.whenComplete(() => print("?????? ?????? ?????? ????????? ????????? ??????"));

      final uploadTask1 = realImageRef.putFile(_imageFileToUpload!);
      final snapshot1 = await uploadTask1.whenComplete(() => print("?????? ????????? ????????? ??????"));
      final _realImgURL = await snapshot1.ref.getDownloadURL();

      final uploadTask2 = thumbImageRef.putFile(_thumbnailFileToUpload!);
      final snapshot2 = await uploadTask2.whenComplete(() => print("????????? ????????? ????????? ??????"));
      final _thumbImgURL = await snapshot2.ref.getDownloadURL();

      // 3. ?????? ????????? ??????
      final result = await CustomAPIService.updateImage(postId, _thumbImgURL, _realImgURL);
      print(result);

      // 4. ?????? ?????? ??????
      FirebaseMessaging.instance.subscribeToTopic("$postId");

      setState(() {
        _isUploaded = true;
      });
    }
  }

  _sendEmail(DictDetailResponse pediaDetail, User user) async {
    final result = await WoongJinAPIService.sendDictEmail(pediaDetail.apiId, pediaDetail.name, user);
    if (result) {
      SingleMessageDialog.alert(context, "????????? ??????????????? ??????????????????.\n(${user.email})", delayTime: Duration(seconds: 2));
    } else {
      SingleMessageDialog.alert(context, "?????? ?????? ??????\n(${user.email})", delayTime: Duration(seconds: 2));
    }
  }
}
