import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_account.dart';

import 'image_cut_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  R2Account? _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final account = await R2DBHelper().getLocalAccount();
    setState(() {
      _account = account;
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    await _requestPermissions();  // Request permissions

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: const Text('拍照'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('从手机相册选择'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('取消'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      // Navigate to the Image Cut Screen to crop/adjust the image
      final croppedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageCutScreen(imageFile: image),
        ),
      );

      if (croppedImage != null) {
        setState(() {
          _account?.avatarPath = croppedImage.path;
          R2DBHelper().saveAccount(_account!);
        });
      }
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('骑行名片'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 16.0
            ),
            title: const Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: Text('更换头像', style: TextStyle(fontSize: 24.0)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Ensures the row takes the minimum space needed
              children: [
                FutureBuilder<Image>(
                  future: _account?.getAvatar(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                      return ClipOval(
                        child: SizedBox(
                          width: 70.0,  // Set the desired width
                          height: 70.0, // Set the desired height
                          child: Image.asset(
                            'assets/images/default_avatar.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                    return ClipOval(
                      child: SizedBox(
                        width: 70.0,  // Set the desired width
                        height: 70.0, // Set the desired height
                        child: snapshot.data!,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20.0),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showImageSourceActionSheet(context),
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 16.0
            ),
            title: const Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: Text('昵称', style: TextStyle(fontSize: 24.0),)
            ),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${_account?.nickname}', style: TextStyle(fontSize: 24.0),),
                  const SizedBox(width: 20.0,),
                  const Icon(Icons.chevron_right),
                ]), // Placeholder for nickname
            onTap: () {
              // Handle nickname modification
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController nicknameController = TextEditingController(text: 'Jack'); // Placeholder
                  return AlertDialog(
                    title: const Text('修改昵称'),
                    content: TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(hintText: "请输入新的昵称"),
                      onSubmitted: (value) {
                        Navigator.pop(context, value);
                      },
                    ),
                    actions: [
                      TextButton(
                        child: const Text("取消"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text("保存"),
                        onPressed: () {
                          Navigator.pop(context, nicknameController.text);
                        },
                      ),
                    ],
                  );
                },
              ).then((newNickname) {
                if (newNickname != null && newNickname.isNotEmpty) {
                  setState(() {
                    // Save the new nickname
                    _account?.nickname = newNickname;
                    R2DBHelper().saveAccount(_account!);
                  });
                }
              });
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}