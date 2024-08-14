import 'package:flutter/material.dart';
import "package:r2cyclingapp/database/r2_db_helper.dart";
import "package:r2cyclingapp/database/r2_account.dart";
import 'package:r2cyclingapp/database/r2_token_storage.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

import 'user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  Widget _userInfoWidget() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          vertical: 30.0,
          horizontal: 16.0
      ),
      leading: FutureBuilder<Image>(
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
      title: Text(_account?.nickname ?? 'User', style: const TextStyle(fontSize: 24.0),),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
      },
    );
  }

  Widget _aboutWidget(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding (
          padding: EdgeInsets.all(10.0),
          child:Text(
            '关于 R2 Cycling',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Padding (
          padding: EdgeInsets.fromLTRB(20.0,0.0,20.0,10.0),
          child: Text(
            '专为骑行爱好者设计的智能伙伴，个性化您的骑行装备，让每次出行都充满乐趣。\n'
                '我们的使命是连接骑行世界，让沟通更便捷，让安全更有保障。',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    );
  }

  Widget _versionWidget(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding (
          padding: EdgeInsets.all(10.0),
          child:Text(
            '版本',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Center (
          child: Text(
            '1.0.0 Beta #build 24938',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color(0xFF639765)
            ),
          ),
        ),
      ],
    );
  }

  Widget _copyrightWidget(BuildContext context) {
    return const Column(
      children: [
        Text(
          '洛克之路（深圳）科技有限责任公司 设计开发',
          textAlign: TextAlign.center,
        ),
        Text(
          'Designed & Developed by RockRoad Tech.',
          textAlign: TextAlign.center,
        ),
        Text(
          '© 2024 All Rights Reserved.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // child: _account == null ? const CircularProgressIndicator() : Column(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Avatar and Nickname
            _userInfoWidget(),
            const Divider(),
            // 2. R2 Cycling Introduction
            const SizedBox(height:10.0),
            _aboutWidget(context),
            const SizedBox(height: 10.0),
            const Divider(),
            // 3. App Version
            const SizedBox(height:10.0),
            _versionWidget(context),
            const SizedBox(height: 10.0),
            // 4. Logout Button
            Expanded(
              child:Center(
                child: R2FlatButton(
                  text: '退出登录',
                  onPressed: () async {
                    await R2DBHelper().deleteAccount(_account?.account ?? '');
                    await R2TokenStorage.deleteToken();
                    Navigator.of(context).pop(true);
                    },
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            // 5. Company Info and Copyright
            Center(child:_copyrightWidget(context)),
          ],
        ),
      ),
    );
  }
}