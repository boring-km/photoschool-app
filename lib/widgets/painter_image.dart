import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' as size;
import 'package:painter/painter.dart';
import 'package:path_provider/path_provider.dart';

import 'hero_dialog_route.dart';
import 'loading.dart';

class PainterWidget extends StatefulWidget {

  final File backgroundImageFile;

  const PainterWidget({Key? key, required this.backgroundImageFile}) : super(key: key);

  @override
  _PainterWidgetState createState() => _PainterWidgetState();
}

class _PainterWidgetState extends State<PainterWidget> {

  late File backgroundImageFile;
  final PainterController _controller = _newController();
  GlobalKey<State<StatefulWidget>> globalKey = GlobalKey();
  Image? _image;
  late double _imageWidth;
  late double _imageHeight;
  Color? _color;

  final _titleController = TextEditingController();
  var _titleText = "  제목 입력  ";

  bool _isTapped = false;
  bool _isUploading = false;

  @override
  void initState() {
    backgroundImageFile = widget.backgroundImageFile;
    _imageWidth = size.ImageSizeGetter.getSize(FileInput(backgroundImageFile)).width + 0.0;
    _imageHeight = size.ImageSizeGetter.getSize(FileInput(backgroundImageFile)).height + 0.0;
    print("이미지 너비: $_imageWidth, 이미지 높이: $_imageHeight");
    super.initState();
    _color = Colors.white;
  }

  static PainterController _newController() {
    var controller = PainterController();
    controller.thickness = 5.0;
    controller.backgroundColor = Colors.transparent;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return _isUploading ?
    LoadingWidget.buildLoadingView("그림 만드는 중", 30) :
    Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: RepaintBoundary(
              key: globalKey,
              child: Container(
                width: _imageWidth,
                height: _imageHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(backgroundImageFile),
                  ),
                ),
                child: Painter(_controller)
              ),
            ),
          ),
          _image != null ? _image! : Container(),
          Positioned(
              left: 10,
              top: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          onPressed: () {
                            if (!_controller.isEmpty) {
                              _controller.undo();
                            }
                          },
                          backgroundColor: Colors.yellow,
                          heroTag: "undo",
                          child: Icon(
                            Icons.undo,
                            color: Colors.black
                          ),
                        ),
                      ),
                      Text("되돌리기", style: TextStyle(color: Colors.white, fontSize: 20),)
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          onPressed: _controller.clear,
                          heroTag: "clear",
                          backgroundColor: Colors.white70,
                          child: Icon(Icons.delete, color: Colors.white,),
                        ),
                      ),
                      Text("전부 지우기", style: TextStyle(color: Colors.white, fontSize: 20),)
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _controller.eraseMode = !_controller.eraseMode;
                            });
                          },
                          heroTag: "mode",
                          backgroundColor: _controller.eraseMode ? Colors.orange : Colors.blue,
                          child: RotatedBox(
                              quarterTurns: _controller.eraseMode ? 2 : 0,
                              child: _controller.eraseMode ? Icon(Icons.edit_off_outlined) : Icon(Icons.create),
                          )
                        ),
                      ),
                      Text(_controller.eraseMode ? "지우개" : "그리기", style: TextStyle(color: Colors.white, fontSize: 20),)
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          onPressed: () async {
                            await _pickColor(context, Colors.white);
                          },
                          heroTag: "pick",
                          backgroundColor: Colors.red,
                          child: Icon(Icons.brush, color: _color == null ? Colors.black : _color),
                        ),
                      ),
                      Text("색 바꾸기", style: TextStyle(color: Colors.white, fontSize: 20),)
                    ],
                  )
                ],
              )
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("제목 설정", style: TextStyle(fontSize: 24, color: Colors.white),),
                ),
                _isTapped ?
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8.0))
                  ),
                  width: 200,
                  height: 40,
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      floatingLabelBehavior:FloatingLabelBehavior.never,
                      border: UnderlineInputBorder(),
                      labelText: '8자 이내로 입력',
                      labelStyle: TextStyle(color: Colors.black45),
                      fillColor: Colors.black,),
                    autofocus: true,
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    onSubmitted: (text) {
                      setState(() {
                        _titleText = text;
                        _isTapped = false;
                      });
                    },
                  )
                ) :
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTapped = true;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),
                    height: 40,
                    child: Center(
                      child: Text(_titleText,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("두께 조절", style: TextStyle(fontSize: 24, color: Colors.white),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            child: Slider(
                              value: _controller.thickness,
                              onChanged: (value) => setState(() {
                                _controller.thickness = value;
                              }),
                              min: 1,
                              max: 40,
                              activeColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text("원본 업로드", style: TextStyle(color: Colors.white, fontSize: 20),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        heroTag: "org",
                        onPressed: () {
                          setState(() {
                            _isUploading = true;
                          });
                          _capture(context, isOrigin: true);
                        },
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.check),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("업로드", style: TextStyle(color: Colors.white, fontSize: 20),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        heroTag: "full",
                        onPressed: () {
                          setState(() {
                            _isUploading = true;
                          });
                          _capture(context);
                        },
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  void _capture(BuildContext context, {bool? isOrigin}) async {
    if (isOrigin != null) {
      Navigator.of(context).pop({
        "image": backgroundImageFile,
        "title": _titleController.text,
        "quality": 50,
      });
    } else {
      print("START CAPTURE");
      var renderObject = globalKey.currentContext!.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        var boundary = renderObject;
        var image = await boundary.toImage();
        final directory = (await getApplicationDocumentsDirectory()).path;
        var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        var pngBytes = byteData!.buffer.asUint8List();
        print(pngBytes);
        var imgFile = File('$directory/screenshot.png');
        final imageFile = await imgFile.writeAsBytes(pngBytes);
        print("FINISH CAPTURE ${imgFile.path}");
        Navigator.of(context).pop({
          "image": imageFile,
          "title": _titleController.text,
          "quality": 20,
        });
      }
    }

  }

  _pickColor(BuildContext context, Color color) async {
    var pickerColor = color;
    final result = await Navigator.of(context).push(HeroDialogRoute(
        builder: (context) => Center(
            child: AlertDialog(
                title: Center(child: Text("색 고르기", style: TextStyle(fontSize: 28),)),
                content: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (c) => pickerColor = c,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Container(
                                width: 150,
                                height: 40,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(color);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.grey
                                    ),
                                    child: Text("닫기", style: TextStyle(fontSize: 28),)),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(pickerColor);
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.green
                                ),
                                child: Text("선택하기", style: TextStyle(fontSize: 28),)),
                              )
                          ],
                        )
                      ],
                    )))
        )
    ));
    setState(() {
      _color = result;
      _controller.drawColor = result;
    });
  }
}
