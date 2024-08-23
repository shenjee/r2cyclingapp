import 'dart:convert';
import 'dart:core';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:r2cyclingapp/login/password_recover_screen.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';

import 'package:r2cyclingapp/screens/home_screen.dart';
import 'login_base_screen.dart';

class UserLoginScreen extends LoginBaseScreen {
  const UserLoginScreen({super.key});

  @override
  LoginBaseScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends LoginBaseScreenState {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mainButtonTitle = '登录';
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha512.convert(bytes);
    return digest.toString();
  }

  Future<void> _requestLogin() async {
    // get uuid as session id
    final prefs = await SharedPreferences.getInstance();
    String? sid = prefs.getString('sessionId');
    if (null == sid) {
      var uuid = const Uuid();
      sid = uuid.v4();
      await prefs.setString('sessionId', sid);
    }

    final String phonenumber = _phoneController.text;
    final String password = _passwordController.text;

    final t = await R2Storage.getToken();
    String? combined;
    String? hashedCombined;
    combined = '$phonenumber$password';
    hashedCombined = _hashPassword(combined);
    debugPrint('Phone number and password combined:');
    debugPrint('  combined: $combined');
    debugPrint('  hashed_combined: $hashedCombined');

    final request = R2HttpRequest();
    final response = await request.sendRequest(
      api: 'common/r2passwordLogin',
      token: t,
      body: {
        'sid': sid,
        'loginId': phonenumber,
        'userPsw': hashedCombined,
        'validateCode':''
      },
    );

    if (true == response.success) {
      debugPrint('Login by phone number + password');
      debugPrint('  Message: ${response.message}');
      debugPrint('  Code: ${response.code}');
      debugPrint('  Result: ${response.result}');

      // retrieve the token and password-setting indicator
      final Map<String, dynamic> data = response.result;
      final token = data['token'];
      debugPrint('$runtimeType :  parse result:');
      debugPrint('$runtimeType :    token:\n $token');

      final manager = R2UserManager();
      manager.saveToken(token);
      manager.saveAccountWithToken(token);

      // save token
      await R2Storage.saveToken(token);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        debugPrint('Failed to request login: ${response.code}');
      }
    }
  }

  @override
  Widget topWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(40.0),
        child:Image.asset('assets/images/r2cycling_logo.png')
    );
  }

  @override
  Widget centerWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:<Widget> [
        // text field for entering phone number
        R2UserTextField(
          prefixWidget: const Text(
            '+86',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          hintText: '请输入手机号',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height:20),
        // text field for entering password
        R2UserTextField(
          prefixWidget: const Text(
            '[***]',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          hintText: '请输入密码',
          controller: _passwordController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height:30),
        Container (
          width: 340,
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserRegisterScreen()),
              );
              },
            child: const Text('验证码登录'),
          ),
        )
      ]
    );
  }

  @override
  void mainButtonClicked() {
    // TODO: implement main_button_clicked
    super.mainButtonClicked();
    debugPrint('$runtimeType : main button clicked');
    _requestLogin();
  }

  @override
  Widget bottomWidget(BuildContext context) {
    return Container (
        width: 340,
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        alignment: Alignment.topRight,
        child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PasswordRecoverScreen()),
          );
          },
          child: const Text('忘记密码？'),
        )
    );
  }
}