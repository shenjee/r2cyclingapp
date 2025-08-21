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
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/usermanager/r2_account.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

import 'image_cut_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _manager = R2UserManager();
  R2Account? _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final account = await _manager.localAccount();
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
                title: Text(AppLocalizations.of(context)!.takePhoto),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.selectFromAlbum),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.cancel),
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
          // save the image path and upload to server
          _account?.avatarPath = croppedImage.path;
          _manager.updateAvatar(value: croppedImage.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.personalCenter),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Column(
          children: [
            const Divider(color: AppConstants.primaryColor200),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 16.0
              ),
              title: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: Text(AppLocalizations.of(context)!.avatar, style: const TextStyle(fontSize: 24.0, color: AppConstants.textColor)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Ensures the row takes the minimum space needed
                children: [
                  FutureBuilder<Image>(
                    future: _account?.getAvatar(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 30.0,
                          backgroundColor: Colors.transparent,
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return const CircleAvatar(
                          radius: 30.0,
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.error),
                        );
                      } else {
                        return CircleAvatar(
                          radius: 30.0,
                          backgroundColor: Colors.transparent,
                          backgroundImage: snapshot.data?.image,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 20.0),
                  Icon(Icons.chevron_right, color: Colors.grey[500]),
                ],
              ),
              onTap: () => _showImageSourceActionSheet(context),
            ),
            const Divider(color: AppConstants.primaryColor200),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 16.0
              ),
              title: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: Text(AppLocalizations.of(context)!.nickname, style: const TextStyle(fontSize: 24.0, color: AppConstants.textColor),)
              ),
              trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_account?.nickname}', style: const TextStyle(fontSize: 24.0),),
                    const SizedBox(width: 20.0,),
                    Icon(Icons.chevron_right, color: Colors.grey[500],),
                  ]), // Placeholder for nickname
              onTap: () {
                // Handle nickname modification
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController nicknameController = TextEditingController(); // Placeholder
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.modifyNickname),
                      content: TextField(
                        controller: nicknameController,
                        decoration: InputDecoration(hintText: AppLocalizations.of(context)!.enterNewNickname),
                        onSubmitted: (value) {
                          Navigator.pop(context, value);
                        },
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: const TextStyle(fontSize: 20.0,color: AppConstants.primaryColor),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.save,
                            style: const TextStyle(fontSize: 20.0, color: AppConstants.primaryColor),
                          ),
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
                      _manager.updateNickname(value: newNickname);
                    });
                  }
                });
              },
            ),
            const Divider(color: AppConstants.primaryColor200),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 16.0
              ),
              title: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: Text(AppLocalizations.of(context)!.accountManagement, style: const TextStyle(fontSize: 24.0, color: AppConstants.textColor)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 20.0),
                  Icon(Icons.chevron_right, color: Colors.grey[500]),
                ],
              ),
              onTap: () {
                // Handle account management
              },
            ),
            const Divider(color: AppConstants.primaryColor200),
            // Add some spacing before the logout button
            const Spacer(),
            // Logout Button at the bottom
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: R2FlatButton(
                    text: AppLocalizations.of(context)!.logout,
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                      await _accountLogout();
                    },
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
    ),);
  }

  Future<void> _accountLogout() async {
    final manager = R2UserManager();
    final account = await manager.localAccount();
    if (account != null) {
      await manager.deleteToken();
      await manager.deleteUser(account.uid);
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (Route<dynamic> route) => false,
      );
    }
  }
}