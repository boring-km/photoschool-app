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
import '../widgets/hero_dialog_route.dart';

class PainterImageTest extends StatefulWidget {

  final File backgroundImageFile;

  const PainterImageTest({Key? key, required this.backgroundImageFile}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<PainterImageTest> {

  late File backgroundImageFile;
  final PainterController _controller = _newController();
  GlobalKey<State<StatefulWidget>> globalKey = GlobalKey();
  Image? _image;
  late double _imageWidth;
  late double _imageHeight;

  Color? _color;

  @override
  void initState() {
    backgroundImageFile = widget.backgroundImageFile;
    _imageWidth = size.ImageSizeGetter.getSize(FileInput(backgroundImageFile)).width + 0.0;
    _imageHeight = size.ImageSizeGetter.getSize(FileInput(backgroundImageFile)).height + 0.0;
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
    return Scaffold(
      appBar: AppBar(
          title: const Text('Painter Example'),
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
            child: DrawBar(_controller),
            preferredSize: Size(MediaQuery.of(context).size.width, 30.0),
          )),
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
                          heroTag: "undo",
                          child: Icon(
                            Icons.undo,
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
                          child: Icon(Icons.delete),
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
                          child: RotatedBox(
                              quarterTurns: _controller.eraseMode ? 2 : 0,
                              child: _controller.eraseMode ? Icon(Icons.edit_off_outlined) : Icon(Icons.create),
                          )
                        ),
                      ),
                      Text(_controller.eraseMode ? "그리기" : "지우개", style: TextStyle(color: Colors.white, fontSize: 20),)
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
                          child: Icon(Icons.brush, color: _color == null ? Colors.white : _color),
                        ),
                      ),
                      Text("색 바꾸기", style: TextStyle(color: Colors.white, fontSize: 20),)
                    ],
                  )
                ],
              )
          ),
          Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: _capture,
                backgroundColor: Colors.green,
                child: Icon(Icons.check),
              ),
          )
        ],
      )
    );
  }

  void _capture() async {
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
      imgFile.writeAsBytes(pngBytes);
      print("FINISH CAPTURE ${imgFile.path}");
      setState(() {
        _image = Image.file(imgFile, width: 300, height: 300,);
      });
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

class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller);

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                  child: Slider(
                    value: _controller.thickness,
                    onChanged: (value) => setState(() {
                      _controller.thickness = value;
                    }),
                    min: 1.0,
                    max: 40.0,
                    label: "${_controller.thickness}",
                    activeColor: Colors.white,
                  ));
            })),
      ],
    );
  }
}
