import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';

class CropImageScreen extends StatefulWidget {
  String sourcePath;

  CropImageScreen({Key? key, required this.sourcePath}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CropImageScreenState();
}

class CropImageScreenState extends State<CropImageScreen> {
  final cropKey = GlobalKey<CropState>();
  File? _originalImage;
  File? _sampleImage;

  @override
  void dispose() {
    super.dispose();

    if(_sampleImage != null) {
      _sampleImage!.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick an option'),
      ),
      body: FutureBuilder<File>(
        future: _openImage(widget.sourcePath),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 20.0),
                child: _buildCroppingImage(context, snapshot.data!),
              ),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text("データが存在しません");
          } else {
            return Text("ss");
          }
        },
      ),
    );
  }

  Widget _buildCroppingImage(context, File sample) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(sample, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text(
                  'Crop Image',
                  style: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(color: Colors.white),
                ),
                onPressed: () => _cropImage(),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<File> _openImage(String sourcePath) async {
    final file = File(sourcePath);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredWidth: 100,
      preferredHeight: 300,
    );

    if(_sampleImage != null) {
      _sampleImage!.delete();
    }
    if(_originalImage != null) {
      _originalImage!.delete();
    }

    _sampleImage = sample;
    _originalImage = file;

    return Future.value(sample);
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    print(scale);
    print(area);
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _originalImage!,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    debugPrint('$file');

    Navigator.pop(context, '${file.path}');
  }
}
