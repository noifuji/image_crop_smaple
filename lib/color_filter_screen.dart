import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ColorFilterScreen extends StatefulWidget {
  final GlobalKey _globalKey = GlobalKey();
  String sourcePath;

  ColorFilterScreen({Key? key, required this.sourcePath}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ColorFilterScreenState();
}

class ColorFilterScreenState extends State<ColorFilterScreen>{
  static const ColorFilter identity = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);
  ColorFilter _colorFilter = identity;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick an option'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 0.8 * screenWidth,
                maxHeight: 0.7 * screenHeight,
              ),
              child: RepaintBoundary(
                key: widget._globalKey,
                child: ColorFiltered(colorFilter: _colorFilter,
                child: Image.file(File(widget.sourcePath)),)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _colorFilter = const ColorFilter.matrix(<double>[
                      0.393, 0.769, 0.189, 0, 0,
                      0.349, 0.686, 0.168, 0, 0,
                      0.272, 0.534, 0.131, 0, 0,
                      0,     0,     0,     1, 0,
                    ]);
                  });
                },
                child: const Text('sepia'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _colorFilter = const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]);
                  });
                },
                child: const Text('greyscale '),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  RenderRepaintBoundary? boundary = widget._globalKey.currentContext
                      ?.findRenderObject() as RenderRepaintBoundary?;
                  if (boundary == null) {
                    return;
                  }
                  ui.Image image = await boundary.toImage(pixelRatio: 1);
                  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

                  if(byteData == null) {
                    return;
                  }

                  var uuid = Uuid();
                  var newId = uuid.v4();

                  var appDir = await getTemporaryDirectory();
                  var filePath = '${appDir.path}/$newId.png';
                  final file = File(filePath);
                  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

                  Navigator.pop(context, '$filePath');
                },
                child: const Text('Done'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
