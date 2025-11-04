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

import 'verification_screen.dart';
import 'password_setting_screen.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';

class PasswordRecoverScreen extends VerificationScreen {
  const PasswordRecoverScreen({super.key});

  @override
  PasswordRecoverScreenState createState() => PasswordRecoverScreenState();
}

class PasswordRecoverScreenState extends VerificationScreenState {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainButtonTitle = AppLocalizations.of(context)!.nextStep;
  }

  @override
  void onTokenRetrieved(String token) async {
    final userManager = R2UserManager();
    final currentAccount = await userManager.localAccount();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PasswordSettingScreen(
                phoneNumber: currentAccount?.phoneNumber,
                title: AppLocalizations.of(context)!.resetPassword,
              )),
    );
  }
}
