import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart'; // For cropping the image
import 'dart:io';

class ImageCutScreen extends StatefulWidget {
  final File imageFile;

  ImageCutScreen({required this.imageFile});

  @override
  _ImageCutScreenState createState() => _ImageCutScreenState();
}

class _ImageCutScreenState extends State<ImageCutScreen> {
  File? _croppedImage;

  @override
  void initState() {
    super.initState();
    _cropImage();
  }

  Future<void> _cropImage() async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      aspectRatio:const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪',
          toolbarColor: Colors.green,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: '裁剪',
          cancelButtonTitle: '取消',
          doneButtonTitle: '裁剪',
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        _croppedImage = File(cropped.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _croppedImage == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.file(_croppedImage!),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                iconSize: 50,
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                iconSize: 50,
                onPressed: () {
                  Navigator.pop(context, _croppedImage);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}