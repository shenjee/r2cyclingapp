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
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

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
        Padding (
          padding: const EdgeInsets.fromLTRB(20.0,0.0,20.0,10.0),
          child: Text(
            AppLocalizations.of(context)!.appDescription,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 18.0, color: AppConstants.textColor),
          ),
        ),
      ],
    );
  }

  Widget _copyrightWidget(BuildContext context) {
    return Column(
      children: [
        Center(
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final packageInfo = snapshot.data!;
                return Text(
                   '${AppLocalizations.of(context)!.version}: ${packageInfo.version} build ${packageInfo.buildNumber}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: AppConstants.primaryColor
                  ),
                );
              } else {
                return const Text(
                  'Loading version...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: AppConstants.primaryColor
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.companyInfo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppConstants.textColor),
        ),
        const Text(
          '© 2025 All Rights Reserved.',
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
            _aboutWidget(context),
            //const Divider(color: AppConstants.primaryColor200),
            // 3. App Version
            //_versionWidget(context),
            // 4. Company Info and Copyright
            const Spacer(),
            Center(child:_copyrightWidget(context)),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}