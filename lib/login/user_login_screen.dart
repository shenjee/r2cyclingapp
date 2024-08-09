import 'dart:convert';
import 'dart:core';
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r2cyclingapp/login/password_recover_screen.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/database/r2_token_storage.dart';
import 'package:r2cyclingapp/connection/http/r2_http_response.dart';

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

  Future<void> _login() async {
    final String _phonenumber = _phone_controller.text;
    final String _password = _password_controller.text;

    final t = await TokenStorage.getToken();
    print('get token: ${t}');

    String? combined;
    String? hashed_combined;
    combined = '${_phonenumber}${_password}';
    hashed_combined = _hashPassword(combined);
    print('Phone number and password combined:');
    print('  combined: ${combined}');
    print('  hashed_combined: ${hashed_combined}');

    final response = await http.post(
      Uri.parse('http://r2cycling.imai.site/api/common/passwordLogin'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'apiToken': '$t',
      },
      body: {
        'sid': '825067',
        'loginId': _phonenumber,
        'userPsw': hashed_combined,
        'validateCode':''
      },
    );

    if (200 == response.statusCode) {
      final r = R2HttpResponse.fromJson(response.body);
      print('Login by phonenumber + password');
      print('  Success: ${r.success}');
      print('  Message: ${r.message}');
      print('  Code: ${r.code}');
      print('  stackTracke: ${r.stackTracke}');
      print('  Result: ${r.result}');
      if (true == r.success) {
        // retrieve the token and password-setting indicator
        final Map<String, dynamic> data = r.result;
        final token = data['token'];
        final need_set_passwd = data['defaultPassword'];
        print('  parse result:');
        print('    token:\n ${token}');
        print('    need_set_passwd: ${need_set_passwd}');

        await TokenStorage.saveToken(token);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } else if (500 == response.statusCode) {
      print('wrong user/password: ${response.body}');
    } else {
      print('Failed to login: ${response.body}');
    }
  }

  @override
  Widget topWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(40.0),
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
          prefixWidget: Text(
            '+86',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          hintText: '请输入手机号',
          controller: _phone_controller,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height:20),
        // text field for entering password
        R2UserTextField(
          prefixWidget: Text(
            '[***]',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          hintText: '请输入密码',
          controller: _password_controller,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height:30),
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
            child: Text('验证码登录'),
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
    _login();
  }

  @override
  Widget bottomWidget(BuildContext context) {
    return Container (
        width: 340,
        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
        alignment: Alignment.topRight,
        child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PasswordRecoverScreen()),
          );
          },
          child: Text('忘记密码？'),
        )
    );
  }
}