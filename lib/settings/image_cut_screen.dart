// Copyright (c) 2025 RockRoad Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ImageCutScreen extends StatefulWidget {
  final File imageFile;

  const ImageCutScreen({super.key, required this.imageFile});

  @override
  State<ImageCutScreen> createState() => _ImageCutScreenState();
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
    } else {
      // If cropping was cancelled, pop the screen with null result
      if (mounted) {
        Navigator.pop(context, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _croppedImage == null
          ? const Center(child: CircularProgressIndicator())
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
                icon: const Icon(Icons.cancel, color: Colors.red),
                iconSize: 50,
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
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