import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photoschool/dto/dict/dict_detail_response.dart';
import 'package:photoschool/dto/photos/photo_response.dart';
import 'package:photoschool/services/woongjin_api.dart';

import '../dto/dict/dict_response.dart';
import '../res/colors.dart';
import '../widgets/app_bar_base.dart';

class PediaDetailScreen extends StatefulWidget {

  final DictResponse _pedia;
  final User _user;

  PediaDetailScreen(this._pedia, {Key? key, required User user}): _user = user,
        super(key: key);

  @override
  _PediaDetailState createState() => _PediaDetailState(_pedia);
}

class _PediaDetailState extends State<PediaDetailScreen> {

  final DictResponse _pedia;
  late DictDetailResponse _pediaDetail;
  late User _user;
  double baseSize = 100;
  List<PhotoResponse> _subImageList = [];

  bool _isDetailLoaded = false;

  _PediaDetailState(this._pedia);

  @override
  void initState() {
    _user = widget._user;
    _loadPediaDetail();
    super.initState();
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

    baseSize = w > h ? h / 10 : w / 10;
    var boxRounded = w > h ? h / 30 : w / 30;

    return !_isDetailLoaded ? Scaffold(
      backgroundColor: CustomColors.deepblue,
      body: Center(
        child: Text("로딩중", style: TextStyle(color: Colors.white, fontSize: baseSize * 3),),
      ),
    ) : Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(user: _user, image: "creature"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(baseSize/3),
          child: Center(
            child: Container(
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
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: baseSize/10),
                                child: Icon(Icons.assistant_navigation),
                              ),
                              Text(_pediaDetail.category1, style: TextStyle(color: Colors.black, fontSize: baseSize/3),),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: baseSize/10),
                                child: Icon(Icons.arrow_forward_ios_rounded),
                              ),
                              Text(_pediaDetail.category2, style: TextStyle(color: Colors.black, fontSize: baseSize/3),),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: baseSize/10),
                                child: Icon(Icons.arrow_forward_ios_rounded),
                              ),
                              Text(_pediaDetail.category3, style: TextStyle(color: Colors.black, fontSize: baseSize/3),),
                            ],
                          ),
                          _pedia.imageURLs.isNotEmpty ? ElevatedButton(
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(boxRounded)), primary: Colors.blue, onSurface: Colors.blueAccent),
                              onPressed: () {
                                // _showSelectSource(context);
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
                              )
                          ) : Container(),
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
                                  height: 350,
                                  child: Center(
                                    child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: _buildImages(baseSize, boxRounded),
                                    ),
                                  ),
                                )
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: baseSize / 6, left: baseSize / 2),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_pedia.name, style: TextStyle(fontSize: baseSize * (2 / 3), fontWeight: FontWeight.w700, color: Colors.black),),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: baseSize / 10),
                                    child: Text("(${_pedia.subName})", style: TextStyle(fontSize: baseSize * (1 / 3), color: Colors.black),),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: baseSize / 10, left: baseSize / 2, right: baseSize / 2),
                            child: Text(_pediaDetail.detail, style: TextStyle(color: Colors.black, fontSize: baseSize / 3),)
                          )
                        ],
                      )
                  ),
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
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: baseSize / 3),
            child: Container(
              child: Center(
                  child: Image.network(
                    url,
                    height: baseSize * 8,
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
          onTap: () {},
          child: Center(
            child: Image.network(
              subItem.imgURL,
              width: 400,
            ),
          ),
        ),
      ));
    }

    return resultList;
  }

}