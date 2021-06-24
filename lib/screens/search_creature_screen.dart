import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../dto/searched_detail_item.dart';
import '../res/colors.dart';
import '../services/public_api.dart';
import '../widgets/app_bar_base.dart';
import 'creature_detail_screen.dart';

class SearchCreatureScreen extends StatefulWidget {

  SearchCreatureScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _FindCreatureState createState() => _FindCreatureState();
}

class _FindCreatureState extends State<SearchCreatureScreen> {
  final _creatureSearchController = TextEditingController();
  int _currentPage = 1;
  int received = -1;
  List<SearchedDetailItem> dataList = [];
  late User _user;

  @override
  void initState() {
    _user = widget._user;
    _getCreatureSearchedListView(_creatureSearchController.text, _currentPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var base = w > h ? w / 10 : h / 10;
    var buttonWidth = w > h ? w / 15 : h / 15;
    var buttonHeight = w > h ? h / 15 : w / 15;
    var buttonFontSize = w > h ? h / 40 : w / 40;

    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(user: _user,),
      ),
      body: Padding(
        padding: EdgeInsets.all(w / 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white30,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(h / 50),
                    child: Container(
                      width: w * (2 / 3),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.all(Radius.circular(h / 40)),
                          border: Border.all(width: 2, color: Colors.black)),
                      child: Padding(
                        padding: EdgeInsets.only(left: h / 80, right: 80),
                        child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText:
                              '동물, 식물, 곤충의 이름을 입력해주세요 ex) 호랑이, 소나무, 나방',
                              labelStyle: TextStyle(color: Colors.black45),
                              fillColor: Colors.black),
                          style: TextStyle(color: Colors.black),
                          controller: _creatureSearchController,
                          onSubmitted: (str) async {
                            _currentPage = 1;
                            dataList.clear();
                            await _getCreatureSearchedListView(str, _currentPage);
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
                          dataList.clear();
                          await _getCreatureSearchedListView(_creatureSearchController.text, _currentPage);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(h / 50),
                                side: BorderSide(color: Colors.black, width: 2.0)),
                            primary: CustomColors.lightGreen,
                            onSurface: Colors.lightGreen),
                        child: Text("검색", style: TextStyle(color: Colors.black, fontSize: buttonFontSize),)),
                  ),
                ],
              ),
            ),
            _buildListView(base)
          ],
        ),
      ),
    );
  }

  _buildListView(double base) {
    var resultList = <Widget>[];
    for (var item in dataList) {
      final name = item.name;
      final type = item.type;
      final imageURL = item.imgUrl1;

      final widget = GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => CreatureDetailScreen(item, user: _user,)
              )
          );
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(base/10)),
            border: Border.all(width: 2, color: Colors.black),
          ),
          child: Padding(
            padding: EdgeInsets.all(base/5),
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                Image.network(imageURL, width: 150, loadingBuilder: (context, child, progress) {
                  if (progress != null) {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                    );
                  } else {
                    return child;
                  }
                }),
                Padding(padding: EdgeInsets.symmetric(horizontal: base/5)),
                Center(child: Text("이름: $name", style: TextStyle(fontSize: base/5, fontWeight: FontWeight.w700, color: Colors.black),)),
                Padding(padding: EdgeInsets.symmetric(horizontal: base/2)),
                Center(child: Text("타입: $type", style: TextStyle(fontSize: base/8, color: Colors.black),))
              ],
            ),
          ),
        ),
      );
      resultList.add(widget);
    }

    return Expanded(
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (scrollEnd) {
            var metrics = scrollEnd.metrics;
            if (metrics.atEdge) {
              if (metrics.pixels != 0) {
                print('page: $_currentPage, received: $received');
                if (received == -1 || received == 8) {
                  _currentPage++;
                  _getCreatureSearchedListView(_creatureSearchController.text, _currentPage);
                }
              }
            }
            return true;
          },
          child: ListView.builder(
            itemCount: resultList.length,
            itemBuilder: (context, index) {
              return resultList[index];
            },
          )
        )
    );
  }

  _getCreatureSearchedListView(String text, int page) async {
    var list = await PublicAPIService.getChildBookSearch(text, page);
    received = list.length;
    for (var item in list) {
      final result = await PublicAPIService.getChildBookDetail(item.apiId);
      if (result != false) {
        setState(() {
          var item = (result as SearchedDetailItem);
          dataList.add(item);
        });
      }
    }
  }
}
