import 'package:flutter/material.dart';

import 'verification_screen.dart';
import 'password_setting_screen.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';

class PasswordRecoverScreen extends VerificationScreen {
  const PasswordRecoverScreen({super.key});

  @override
  PasswordRecoverScreenState createState()=> PasswordRecoverScreenState();
}

class PasswordRecoverScreenState extends VerificationScreenState {
  @override
  void initState() {
    super.initState();
    // mainButtonTitle will be set in build method using localization
  }

  @override
  Widget build(BuildContext context) {
    mainButtonTitle = AppLocalizations.of(context)!.nextStep;
    return super.build(context);
  }

  @override
  void onTokenRetrieved(String token) async {
    final userManager = R2UserManager();
    final currentAccount = await userManager.localAccount();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordSettingScreen(
          phoneNumber: currentAccount?.phoneNumber, title: AppLocalizations.of(context)!.resetPassword,)),
    );
  }
}