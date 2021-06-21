import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoschool/domain/searched_detail_item.dart';
import 'package:photoschool/domain/searched_item.dart';
import 'package:photoschool/res/colors.dart';
import 'package:photoschool/services/public_api.dart';
import 'package:photoschool/widgets/app_bar_base.dart';

class FindCreatureScreen extends StatefulWidget {
  @override
  _FindCreatureState createState() => _FindCreatureState();
}

class _FindCreatureState extends State<FindCreatureScreen> {
  var _creatureSearchController = TextEditingController();
  List<Widget> _creatureSearchedList = [];

  @override
  Widget build(BuildContext context) {

    getCreatureSearchedListView("");

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    double base = w > h ? w / 10 : h / 10;
    double buttonWidth = w > h ? w / 15 : h / 15;
    double buttonHeight = w > h ? h / 15 : w / 15;
    double buttonFontSize = w > h ? h / 40 : w / 40;

    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
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
                              '동물, 식물, 곤충의 이름을 입력해주세요 ex) 사자, 소나무, 나방',
                              labelStyle: TextStyle(color: Colors.black45),
                              fillColor: Colors.black),
                          style: TextStyle(color: Colors.black),
                          controller: _creatureSearchController,
                        ),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: buttonWidth, height: buttonHeight),
                    child: ElevatedButton(
                        onPressed: () async {
                          print(_creatureSearchController.text);
                          await getCreatureSearchedListView(_creatureSearchController.text);
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
            buildListView(base)
          ],
        ),
      ),
    );
  }

  buildListView(double base) {
    return FutureBuilder(
      future: getCreatureSearchedListView(_creatureSearchController.text),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        } else if (snapshot.connectionState == ConnectionState.done) {
          final items = snapshot.data as List<SearchedDetailItem>;
          List<Widget> resultList = [];
          for (var item in items) {
            final name = item.name;
            final type = item.type;
            final imageURL = item.imgUrl1;

            final widget = Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(base/10)),
                border: Border.all(width: 2, color: Colors.black),
              ),
              child: Padding(
                padding: EdgeInsets.all(base/5),
                child: Row(
                  children: [
                    Image.network(imageURL, height: 150,),
                    Padding(padding: EdgeInsets.symmetric(horizontal: base/5)),
                    Text("이름: $name", style: TextStyle(fontSize: base/5, color: Colors.black),),
                    Padding(padding: EdgeInsets.symmetric(horizontal: base/2)),
                    Text("타입: $type", style: TextStyle(fontSize: base/8, color: Colors.black),)
                  ],
                ),
              ),
            );
            resultList.add(widget);
          }
          print(snapshot.data.toString());
          return Expanded(child: ListView(
            shrinkWrap: true,
            children: resultList,));
        }
        return Padding(
          padding: EdgeInsets.all(base),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              CustomColors.firebaseOrange,
            ),
          ),
        );
      },
    );
  }

  Future<List<SearchedDetailItem>> getCreatureSearchedListView(String text) async {
    List<SearchedCreature> list = await PublicAPIService.getChildBookSearch(text, 1);
    _creatureSearchedList.clear();
    List<SearchedDetailItem> resultList = [];
    for (var item in list) {
      final result = await PublicAPIService.getChildBookDetail(item.apiId);
      if (result != false) {
        var item = (result as SearchedDetailItem);
        resultList.add(item);
      }
    }
    return resultList;
  }
}
