import 'package:flutter/material.dart';
import 'dart:io';

import "package:r2cyclingapp/usermanager/r2_user_manager.dart";
import "package:r2cyclingapp/usermanager/r2_account.dart";
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _manager = R2UserManager();
  bool _isLoggedIn = false;
  R2Account? _account;
  File? _avatar;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAvatar();  // Reload the avatar whenever dependencies change (i.e., when returning to this screen)
  }

  Future<void> _loadAvatar() async {
    final manager = R2UserManager();
    final account = await manager.localAccount();
    if (account != null && account.avatarPath.isNotEmpty) {
      setState(() {
        _account = account;
        _avatar = File(account.avatarPath);
      });
    }
  }

  Future<void> _loadAccount() async {
    final account = await _manager.localAccount();
    final token = await _manager.readToken();
    if (null != account && null != token) {
      setState(() {
        _account = account;
        _isLoggedIn = true;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _accountLogout() async {
    _manager.deleteToken();
    _manager.deleteUser(_account!.uid);
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
              radius: 30.0,
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const CircleAvatar(
              radius: 30.0,
              child: Icon(Icons.error),
            );
          } else {
            return CircleAvatar(
              radius: 30.0,
              backgroundImage: snapshot.data?.image,
            );
          }
        },
      ),
      title: Text(_account?.nickname ?? 'User', style: const TextStyle(fontSize: 24.0),),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.pushNamed(context, '/profile');
        _loadAvatar();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Avatar and Nickname
            if (true == _isLoggedIn)
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
            if (true == _isLoggedIn)
              Expanded(
                child:Center(
                  child: R2FlatButton(
                    text: '退出登录',
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                      await _accountLogout();
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