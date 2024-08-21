import 'package:flutter/material.dart';

import 'verification_screen.dart';
import 'password_setting_screen.dart';

class PasswordRecoverScreen extends VerificationScreen {
  const PasswordRecoverScreen({super.key});

  @override
  PasswordRecoverScreenState createState()=> PasswordRecoverScreenState();
}

class PasswordRecoverScreenState extends VerificationScreenState {
  @override
  void initState() {
    super.initState();
    mainButtonTitle = '下一步';
  }

  @override
  void onTokenHandled(String phoneNumber, bool needSetPassword) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordSettingScreen(
          phoneNumber: phoneNumber, title: '重置密码',)),
    );
  }
}