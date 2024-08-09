import 'package:flutter/material.dart';

import 'verification_screen.dart';
import 'password_setting_screen.dart';

class PasswordRecoverScreen extends VerificationScreen {
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
  void is_token_handled(String phone_number, bool void_password) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordSettingScreen(
          phoneNumber: phone_number, title: '重置密码',)),
    );
  }
}