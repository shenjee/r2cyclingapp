import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/r2controls/r2_flash.dart';
import 'package:r2cyclingapp/r2controls/r2_loading_indicator.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/screens/home_screen.dart';
import 'package:r2cyclingapp/constants.dart';
import 'login_base_screen.dart';

class PasswordSettingScreen extends LoginBaseScreen {
  final String? phoneNumber;
  final String? title;

  const PasswordSettingScreen({
    super.key,
    @required this.phoneNumber,
    @required this.title
  });

  @override
  LoginBaseScreenState createState() => _PasswordSettingScreenState();
}

class _PasswordSettingScreenState extends LoginBaseScreenState {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _phoneNumber;
  String? _title;
  // toggle for password visibility
  bool _isPasswordHidden = true;
  bool _isConfirmHidden = true;

  @override
  void initState() {
    super.initState();
    mainButtonTitle = '保存';
    _phoneNumber = (widget as PasswordSettingScreen).phoneNumber;
    _title = (widget as PasswordSettingScreen).title;
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha512.convert(bytes);
    return digest.toString();
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

  Future<void> _setPassword() async {
    debugPrint('1st:${_passwordController.text} 2nd:${_confirmController.text}');
    final isSame = _passwordController.text.compareTo(_confirmController.text);
    final isValidPasswd = _isValidPassword(_passwordController.text);
    if (0 == isSame && true == isValidPasswd) {
      // get uuid as session id
      final prefs = await SharedPreferences.getInstance();
      String? sid = prefs.getString('sessionId');
      if (null == sid) {
        var uuid = const Uuid();
        sid = uuid.v4();
        await prefs.setString('sessionId', sid);
      }

      final manager = R2UserManager();
      final token = await manager.readToken();
      if (null != token) {
        // loading indicator for modification of the password
        if (mounted) {
          R2LoadingIndicator.show(context);
        }

        String? combined;
        String? hashedCombined;

        combined = '$_phoneNumber${_passwordController.text}';
        hashedCombined = _hashPassword(combined);
        debugPrint('combined: $combined');
        debugPrint('hashedCombined: $hashedCombined');

        final request = R2HttpRequest();
        final response = await request.postRequest(
          api: 'user/modUserPass',
          token: token,
          body: {
            'sid': sid,
            'modPassword': hashedCombined,
          },
        );

        // stop the indicator
        if (mounted) {
          R2LoadingIndicator.stop(context);
        }

        if (true == response.success) {
          debugPrint('$runtimeType : Password sent successfully');
          debugPrint('$runtimeType : Message: ${response.message}');
          debugPrint('$runtimeType : Code: ${response.code}');
          debugPrint('$runtimeType : Result: ${response.result}');

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
            );
          }
        } else {
          debugPrint('Failed to set password: ${response.code}');
          if (mounted) {
            R2Flash.showBasicFlash(
                context: context,
                message: '${response.message}（${response.code}）',
                duration: const Duration(seconds: 3),
            );
          }
        }
      }
    } else {
      String warning;
      if (0 != isSame) {
        warning = '两次密码输入不一致';
      } else {
        warning = '密码为不少于8位的数字和字符组合';
      }
      R2Flash.showBasicFlash(
          context: context,
          message: warning,
          duration: const Duration(seconds: 3)
      );
    }
  }

  @override
  Widget topWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 20.0),
        child:Text(
            style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
            _title ??'设置密码'
        ),
    );
  }

  @override
  Widget centerWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:<Widget> [
          Container (
            width: 340,
            alignment: Alignment.centerLeft,
            child: const Text('密码至少8位，包含数字和字母\n'),
          ),
          // text field for entering phone number
          R2UserTextField(
            prefixWidget: Image.asset('assets/icons/icon_password.png', width: 24, height: 24),
            hintText: '输入新密码',
            controller: _passwordController,
            keyboardType: TextInputType.text,
            textVisible: _isPasswordHidden,
            suffixWidget: IconButton(
              icon: Icon(
                _isPasswordHidden ? Icons.visibility_off : Icons.visibility ,
                color: AppConstants.primaryColor200,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordHidden = !_isPasswordHidden;
                });
              },
            ),
          ),
          const SizedBox(height:40.0),
          // text field for entering password
          R2UserTextField(
            prefixWidget: Image.asset('assets/icons/icon_password.png', width: 24, height: 24),
            hintText: '再次确认',
            controller: _confirmController,
            keyboardType: TextInputType.text,
            textVisible: _isConfirmHidden,
            suffixWidget: IconButton(
              icon: Icon(
                _isConfirmHidden ? Icons.visibility_off : Icons.visibility ,
                color: AppConstants.primaryColor200,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmHidden = !_isConfirmHidden;
                });
              },
            ),
          ),
        ]
    );
  }

  @override
  void mainButtonClicked() {
    super.mainButtonClicked();
    _setPassword();
    debugPrint('$runtimeType : main button clicked');
  }
}