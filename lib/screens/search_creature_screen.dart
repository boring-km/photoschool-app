import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../dto/creature/creature_detail_response.dart';
import '../dto/dict/dict_response.dart';
import '../res/colors.dart';
import '../services/public_api.dart';
import '../services/woongjin_api.dart';
import '../widgets/app_bar_base.dart';
import 'creature_detail_screen.dart';
import 'pedia_detail_screen.dart';

class SearchCreatureScreen extends StatefulWidget {

  SearchCreatureScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _FindCreatureState createState() => _FindCreatureState();
}

class _FindCreatureState extends State<SearchCreatureScreen> {
  late User _user;
  final _creatureSearchController = TextEditingController();
  final List<CreatureDetailResponse> _creatureDataList = [];
  final List<DictResponse> _wjPediaList = [];
  bool _isFirstLoading = true;
  bool _isSearching = false;
  int _creatureReceived = -1;
  int _currentPage = 1;

  bool _isLoading = false;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() async {
    _user = widget._user;
    await _searchCreature(_creatureSearchController.text, _currentPage); // 처음에 기본 생물만 검색
  }

  @override
  Widget build(BuildContext context) {

    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var base = w > h ? w / 10 : h / 15;
    var buttonWidth = w > h ? w / 15 : h / 15;
    var buttonHeight = w > h ? h / 15 : w / 15;
    var buttonFontSize = w > h ? h / 35 : w / 35;

    return _isFirstLoading ? Scaffold(
      backgroundColor: CustomColors.orange,
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "SelectWiki",
                child: SvgPicture.asset(
                  'assets/book_reading.svg',
                  height: h / 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(base/2),
                child: Text("로딩중",
                  style: TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            blurRadius: 4.0,
                            color: Colors.black45,
                            offset: Offset(3.0, 3.0)
                        )
                      ],
                      fontSize: buttonFontSize * 3),),
              )
            ],
          ),
        ),
      ),
    ) : Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(user: _user, image: "creature"),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: base / 20, left: base / 4, right: base / 4),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(h / 50),
                    child: Container(
                      width: w * (2 / 3),
                      height: buttonHeight,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.all(Radius.circular(h / 40)),
                          border: Border.all(width: 2, color: Colors.black)),
                      child: Padding(
                        padding: EdgeInsets.only(left: h / 80, right: 80),
                        child: TextField(
                          decoration: InputDecoration(
                            floatingLabelBehavior:FloatingLabelBehavior.never,
                            border: InputBorder.none,
                            icon: Icon(Icons.search, size: base/3, color: Colors.black45,),
                            labelText: '백과사전 검색',
                            labelStyle: TextStyle(color: Colors.black45),
                            fillColor: Colors.black,),
                          style: TextStyle(color: Colors.black, fontSize: base/4),
                          controller: _creatureSearchController,
                          onSubmitted: (str) async {
                            _currentPage = 1;
                            _creatureDataList.clear();
                            _wjPediaList.clear();
                            setState(() {
                              _isSearching = true;
                            });
                            await _allSearch(str);
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: buttonWidth, height: buttonHeight),
                    child: ElevatedButton(
                      onPressed: () async {
                        _currentPage = 1;
                        _creatureDataList.clear();
                        setState(() {
                          _isSearching = true;
                        });
                        await _allSearch(_creatureSearchController.text);
                        setState(() {
                          _isSearching = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(h / 50),),
                          primary: CustomColors.orange,
                          onSurface: Colors.orangeAccent),
                      child: Text("검색",
                        style: TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black45,
                                  offset: Offset(2.0, 2.0)
                              )
                            ],
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w700),)),
                  ),
                ],
              ),
            ),
            !_isSearching ? Container(
              child: Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (scrollEnd) {
                    final metrics = scrollEnd.metrics;
                    if (metrics.atEdge) {
                      if (metrics.pixels != 0) {
                        if (_creatureReceived == -1 || _creatureReceived == 9) {
                          setState(() {
                            _isLoading = true;
                            _currentPage++;
                            _searchCreature(_creatureSearchController.text, _currentPage);
                          });
                        }
                      }
                    }
                    return true;
                  },
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 4 / 5,
                    ),
                    itemCount: _creatureDataList.length + _wjPediaList.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _wjPediaList.length) {
                        return _buildGridViewItem("pedia", _wjPediaList[index], base);
                      } else if (index < _wjPediaList.length + _creatureDataList.length) {
                        return _buildGridViewItem("creature", _creatureDataList[index-_wjPediaList.length], base);
                      } else {
                        return _isLoading ? Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white,),
                                Padding(
                                  padding: EdgeInsets.all(base/10),
                                  child: Text("로딩중", style: TextStyle(color: Colors.white, fontSize: base/2),),
                                )
                              ],
                            ),
                          ),
                        ) : Container();
                      }
                    },
                  ),
                ),
              ),
            ) : Container(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(base/2),
                  child: Text("로딩중",
                    style: TextStyle(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              blurRadius: 4.0,
                              color: Colors.black45,
                              offset: Offset(3.0, 3.0)
                          )
                        ],
                        fontSize: buttonFontSize * 2),),
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _allSearch(String str) async {
    _currentPage = 1;
    await _searchWJDict(str);
    await _searchCreature(str, _currentPage);
  }

  _searchCreature(String text, int page) async {
    var list = await PublicAPIService.getChildBookSearch(text, page);
    _creatureReceived = list.length;
    var resultList = <CreatureDetailResponse>[];
    for (var item in list) {
      final result = await PublicAPIService.getChildBookDetail(item.apiId, text);
      if (result != false) {
        resultList.add(result);
      }
    }
    if (resultList.isNotEmpty) {
      setState(() {
        _creatureDataList.addAll(resultList);
        _isFirstLoading = false;
        _isSearching = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _searchWJDict(String keyword) async {
    _wjPediaList.clear();
    _wjPediaList.addAll(await WoongJinAPIService.searchWJPedia(keyword));
  }

  Widget _buildGridViewItem(String type, dynamic item, double base) {
    if (type == "pedia") {
      final pedia = item as DictResponse;
      var name = pedia.name.length > 9 ? pedia.name.substring(0,9) : pedia.name;
      var subName = pedia.subName.length > 15 || name.length > 5
          ? '${pedia.subName.substring(0,4)}...' : pedia.subName;
      if (name.length > 7) {
        subName = '...';
      }
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => PediaDetailScreen(pedia, user: _user,)
              )
          );
        },
        child: Padding(
          padding: EdgeInsets.all(base/10),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.orangeAccent,
                      blurRadius: 8.0,
                      offset: Offset(4.0, 4.0)
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(base/2))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: base * (2/5)),
                  child: Container(
                    decoration: BoxDecoration(
                        color: CustomColors.orange,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(base/4), bottomRight: Radius.circular(base/4))
                    ),
                    height: base/3,
                    child: Center(
                      child: Text("웅진학습백과", style: TextStyle(color: Colors.white, fontSize: base/4),),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: base/8, left: base/6),
                      child: Text(name, style: TextStyle(color: Colors.black, fontSize: base/3),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: base/20),
                      child: Text('($subName)', style: TextStyle(color: Colors.black, fontSize: base/6),),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: base/6),
                    child: Text(pedia.description, style: TextStyle(color: Colors.black, fontSize: base/5),),
                  ),
                ),
                pedia.imageURLs.isNotEmpty ? Padding(
                  padding: EdgeInsets.only(top: base/10, left: base/6, right: base/6),
                  child: CachedNetworkImage(
                    imageUrl: pedia.imageURLs[0],
                    placeholder: (context, url) => Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.orange, fontSize: base/2),),),),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    height: base*2,
                    fit: BoxFit.fitWidth,
                  )
                ) : Container()
              ],
            ),
          ),
        ),
      );

    } else if (type == "creature") {
      final creature = item as CreatureDetailResponse;
      var creatureName = creature.name.length > 8 ? "${creature.name.substring(0, 8)}..." : creature.name;
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => CreatureDetailScreen(creature, user: _user,)
              )
          );
        },
        child: Padding(
          padding: EdgeInsets.all(base/10),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightGreenAccent,
                    blurRadius: 8.0,
                    offset: Offset(4.0, 4.0)
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(base/2))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: base * (2/5)),
                  child: Container(
                    decoration: BoxDecoration(
                        color: CustomColors.creatureGreen,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(base/4), bottomRight: Radius.circular(base/4))
                    ),
                    height: base/3,
                    child: Center(
                      child: Text("어린이생물도감", style: TextStyle(color: Colors.white, fontSize: base/4),),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: base/8, left: base/6),
                    child: Text(creatureName, style: TextStyle(color: Colors.black, fontSize: base/3),),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: base/6),
                    child: Text(creature.familyType, style: TextStyle(color: Colors.black, fontSize: base/5),),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: base/20, left: base/6, right: base/6),
                    child: CachedNetworkImage(
                      imageUrl: creature.imgUrl1,
                      placeholder: (context, url) => Container(child: Center(child: Text("로딩중", style: TextStyle(color: CustomColors.creatureGreen, fontSize: base/2),),),),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      height: base*2,
                      fit: BoxFit.fitWidth,
                    )
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: base/8, left: base/5, right: base/6),
                    child: Text("출처: 국립수목원", style: TextStyle(color: Colors.black, fontSize: base/6),),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(0),
        child: Container(),
      );
    }
  }

}


