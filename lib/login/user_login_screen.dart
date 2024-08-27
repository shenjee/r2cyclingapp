import 'dart:convert';
import 'dart:core';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:r2cyclingapp/login/password_recover_screen.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/r2controls/r2_flash.dart';
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
  // toggle for password visibility
  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    mainButtonTitle = '登录';
  }

  /*
   * Chinese phone number consists of exactly 11 digits,
   * return: true for matching, false for irregular
   */
  bool _isValidPhoneNumber(String input) {
    final RegExp phoneNumberPattern = RegExp(r'^\d{11}$');

    // Check if the input matches the pattern
    return phoneNumberPattern.hasMatch(input);
  }

  /*
   * The password should be at least 6 characters long. And, the password
   * should consist of letters (uppercase or lowercase), digits,
   * or a combination of both.
   * return: true for matching, false for irregular
   */
  bool _isValidPassword(String input) {
    // Regular expression to match a password that is at least 6 characters long
    // and contains only letters and digits
    final RegExp passwordPattern = RegExp(r'^[a-zA-Z0-9]{6,}$');

    // Check if the input matches the pattern
    return passwordPattern.hasMatch(input);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha512.convert(bytes);
    return digest.toString();
  }

  Future<void> _requestLogin() async {
    final isValidNumber = _isValidPhoneNumber(_phoneController.text);
    final isValidPasswd = _isValidPassword(_passwordController.text);
    if (true == isValidNumber && true == isValidPasswd) {
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

      String? combined;
      String? hashedCombined;
      combined = '$phonenumber$password';
      hashedCombined = _hashPassword(combined);
      debugPrint('Phone number and password combined:');
      debugPrint('  combined: $combined');
      debugPrint('  hashed_combined: $hashedCombined');

      final request = R2HttpRequest();
      final response = await request.postRequest(
        api: 'common/r2passwordLogin',
        body: {
          'sid': sid,
          'loginId': phonenumber,
          'userPsw': hashedCombined,
          'validateCode': ''
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
        manager.requestUserProfile();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        }
      } else {
        debugPrint('Failed to request login: ${response.code}');
        // should show error info
        String warning;
        if (500 == response.code) {
          warning = '用户名或密码输入有误';
        } else {
          warning = '网络错误，请稍后再试';
        }
        if (mounted) {
          R2Flash.showBasicFlash(
              context: context,
              message: warning,
              duration: const Duration(seconds: 3)
          );
        }
      }
    } else {
      // phone number or password are in wrong format
      if (_phoneController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
        String warning;
        if (false == isValidPasswd && false == isValidNumber) {
          warning = '手机号和密码输入格式有误';
        } else if (false == isValidPasswd) {
          warning = '密码为不少于6位的数字和字符组合';
        } else {
          warning = '手机号输入格式有误';
        }
        R2Flash.showBasicFlash(
          context: context,
          message: warning,
          duration: const Duration(seconds: 3),
        );
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
                fontSize: 20,
                color: Colors.grey,
            ),
          ),
          hintText: '请输入手机号',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height:20),
        // text field for entering password
        R2UserTextField(
          prefixWidget: const Icon(Icons.password, color: Colors.grey,),
          hintText: '请输入密码',
          controller: _passwordController,
          keyboardType: TextInputType.text,
          textVisible: _isPasswordHidden,
          suffixWidget: IconButton(
            icon: Icon(
              _isPasswordHidden ? Icons.visibility_off : Icons.visibility ,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordHidden = !_isPasswordHidden;
              });
            },
          ),
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