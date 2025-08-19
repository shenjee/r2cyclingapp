import 'package:flutter/material.dart';
import 'dart:io';

import "package:r2cyclingapp/usermanager/r2_user_manager.dart";
import "package:r2cyclingapp/usermanager/r2_account.dart";
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

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
              backgroundColor: Colors.transparent,
              backgroundImage: snapshot.data?.image,
            );
          }
        },
      ),
      title: Text(_account?.nickname ?? 'User', style: const TextStyle(fontSize: 24.0),),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[500],),
      onTap: () async {
        await Navigator.pushNamed(context, '/profile');
        _loadAvatar();
      },
    );
  }



  Widget _aboutWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding (
          padding: const EdgeInsets.all(10.0),
          child:Text(
            AppLocalizations.of(context)!.aboutR2Cycling,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: AppConstants.textColor),
          ),
        ),
        const SizedBox(height: 10),
        Padding (
          padding: const EdgeInsets.fromLTRB(20.0,0.0,20.0,10.0),
          child: Text(
            AppLocalizations.of(context)!.appDescription,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 20.0, color: AppConstants.textColor),
          ),
        ),
      ],
    );
  }

  Widget _versionWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding (
          padding: const EdgeInsets.all(10.0),
          child:Text(
            AppLocalizations.of(context)!.version,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: AppConstants.textColor),
          ),
        ),
        const SizedBox(height: 10),
        const Center (
          child: Text(
            '1.0.0 Beta #build 24938',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: AppConstants.primaryColor
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
          style: TextStyle(color: AppConstants.textColor),
        ),
        Text(
          'Designed & Developed by RockRoad Tech.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppConstants.textColor),
        ),
        Text(
          '© 2024 All Rights Reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppConstants.textColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0,0.0,16.0,0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppConstants.primaryColor200),
            // 1. User Avatar and Nickname
            if (true == _isLoggedIn)
              _userInfoWidget(),
            const Divider(color: AppConstants.primaryColor200),
            // 2. R2 Cycling Introduction
            const SizedBox(height:10.0),
            _aboutWidget(context),
            const SizedBox(height: 10.0),
            const Divider(color: AppConstants.primaryColor200),
            // 3. App Version
            const SizedBox(height:10.0),
            _versionWidget(context),
            const SizedBox(height: 10.0),
            // 4. Company Info and Copyright
            Center(child:_copyrightWidget(context)),
          ],
        ),
      ),
    );
  }
}