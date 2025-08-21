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

import 'create_group_screen.dart';
import 'join_group_screen.dart';
import 'package:r2cyclingapp/constants.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: ListView(
          children: [
            const Divider(color: AppConstants.primaryColor200),
            ListTile(
              // Height is 120.0, evenly distributed vertical padding is 60.0, take half of it
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 16.0
              ),
              leading: Image.asset(
                'assets/icons/icon_create_group.png',
                width: 50.0,
                height: 50.0,
              ),
              title: Text(
                AppLocalizations.of(context)!.createCyclingGroup, 
                style: const TextStyle(fontSize: 24.0, color: AppConstants.textColor),
                ),
              trailing: const Icon(Icons.chevron_right, color: AppConstants.textColor200,),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateGroupScreen()),
                  );
                  },
            ),
            const Divider(color: AppConstants.primaryColor200),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 16.0
              ),
              leading: Image.asset(
                'assets/icons/icon_join_group.png',
                width: 50.0,
                height: 50.0,
              ),
              title: Text(AppLocalizations.of(context)!.joinCyclingGroup, style: const TextStyle(fontSize: 24.0, color: AppConstants.textColor),),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey[500],),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const JoinGroupScreen()),
                );
              },
            ),
            const Divider(color: AppConstants.primaryColor200),
          ],
        ),
      ),
    );
  }
}