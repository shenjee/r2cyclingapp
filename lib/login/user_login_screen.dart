import 'dart:convert';
import 'dart:core';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:r2cyclingapp/database/r2_account.dart';
import 'package:r2cyclingapp/login/password_recover_screen.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/database/r2_token_storage.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';

import 'package:r2cyclingapp/screens/home_screen.dart';
import 'login_base_screen.dart';

class UserLoginScreen extends LoginBaseScreen {
  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends LoginBaseScreenState {
  final TextEditingController _phone_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

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

    final String _phonenumber = _phone_controller.text;
    final String _password = _password_controller.text;

    final t = await R2TokenStorage.getToken();
    print('get token: $t');

    String? combined;
    String? hashed_combined;
    combined = '${_phonenumber}${_password}';
    hashed_combined = _hashPassword(combined);
    print('Phone number and password combined:');
    print('  combined: ${combined}');
    print('  hashed_combined: ${hashed_combined}');

    final request = R2HttpRequest();
    final response = await request.sendRequest(
      api: 'common/passwordLogin',
      token: t,
      body: {
        'sid': sid,
        'loginId': _phonenumber,
        'userPsw': hashed_combined,
        'validateCode':''
      },
    );

    if (true == response.success) {
      print('Login by phone number + password');
      print('  Message: ${response.message}');
      print('  Code: ${response.code}');
      print('  Result: ${response.result}');

      // retrieve the token and password-setting indicator
      final Map<String, dynamic> data = response.result;
      final token = data['token'];
      final need_set_passwd = data['defaultPassword'];
      final db = R2DBHelper();
      final account = R2Account(account: _phonenumber);

      print('  parse result:');
      print('    token:\n $token');
      print('    need_set_passwd: $need_set_passwd');

      // save account
      db.saveAccount(account);
      // save token
      await R2TokenStorage.saveToken(token);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      print('Failed to login: ${response.code}');
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
          controller: _phone_controller,
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
          controller: _password_controller,
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
                MaterialPageRoute(builder: (context) => UserRegisterScreen()),
              );
              },
            child: const Text('验证码登录'),
          ),
        )
      ]
    );
  }

  @override
  void main_button_clicked() {
    // TODO: implement main_button_clicked
    super.main_button_clicked();
    print('main button clicked');
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
            MaterialPageRoute(builder: (context) => PasswordRecoverScreen()),
          );
          },
          child: const Text('忘记密码？'),
        )
    );
  }
}