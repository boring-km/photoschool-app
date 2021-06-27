import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  late User _user;

  _PediaDetailState(this._pedia);

  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.deepblue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AppBarTitle(user: _user, image: "creature"),
      ),
    );
  }

}