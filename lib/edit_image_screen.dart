import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'color_filter_screen.dart';
import 'crop_image_screen.dart';

class EditImageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditImageScreenState();
}

class EditImageScreenState extends State<EditImageScreen> {
  XFile? _targetFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crop Sample")),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: kIsWeb ? const SizedBox.shrink() :_body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_targetFile != null) {
      return _createImageCard();
    } else {
      return _createImagePickerCard();
    }
  }

  Widget _createImageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _image(),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_targetFile != null) {
      final path = _targetFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                _clear();
              },
              backgroundColor: Colors.redAccent,
              tooltip: 'Delete',
              child: const Icon(Icons.delete),
            ),
            const Text("Delete")
          ],
        ),
        // if (_croppedFile == null)
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                _openImageCropper();
              },
              backgroundColor: const Color(0xFFBC764A),
              tooltip: 'Crop',
              child: const Icon(Icons.crop),
            ),
            const Text("Image_Cropper")
          ]),
        ),
        // if (_croppedFile == null)
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(children: [
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () async {
                await _openColorFilter();
              },
              backgroundColor: const Color(0xFFBC764A),
              tooltip: 'Crop',
              child: const Icon(Icons.filter),
            ),
            const Text("Color Filter")
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(children: [
            FloatingActionButton(
              heroTag: "btn3",
              onPressed: () async {
                await _openImageCrop();
              },
              backgroundColor: const Color(0xFFBC764A),
              tooltip: 'Crop',
              child: const Icon(Icons.crop),
            ),
            const Text("Image_Crop")
          ]),
        ),
      ],
    );
  }

  Widget _createImagePickerCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DottedBorder(
                    radius: const Radius.circular(12.0),
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 4],
                    color: Theme.of(context).highlightColor.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Theme.of(context).highlightColor,
                            size: 80.0,
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Upload an image to start',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    color: Theme.of(context).highlightColor),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    _pickImage();
                  },
                  child: const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openImageCropper() async {
    if (_targetFile == null) {
      return;
    }
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _targetFile!.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );

      print(croppedFile!.path);
        setState(() {
          _targetFile = XFile(croppedFile.path);
        });
  }

  Future<void> _openImageCrop() async {
    print(_targetFile!.path);
    if (_targetFile == null) {
      return;
    }
    print(_targetFile!.path);

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return CropImageScreen(sourcePath: _targetFile!.path);
        },
      ),
    );

    print(result);

    if (result != null) {
      setState(() {
        _targetFile = XFile(result);
      });
    }
  }

  Future<void> _openColorFilter() async {
    if (_targetFile == null) {
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ColorFilterScreen(sourcePath:  _targetFile!.path);
        },
      ),
    );

    if (result != null) {
      setState(() {
        _targetFile = XFile(result);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _targetFile = pickedFile;
      });
    }
  }

  void _clear() {
    setState(() {
      _targetFile = null;
    });
  }
}
