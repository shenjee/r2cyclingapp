import 'package:flutter/material.dart';
import 'package:flash/flash.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:r2cyclingapp/database/r2_account.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'dart:convert';

import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/connection/http/r2_http_response.dart';
import 'package:r2cyclingapp/database/r2_token_storage.dart';
import 'package:r2cyclingapp/screens/home_screen.dart';
import 'login_base_screen.dart';

class PasswordSettingScreen extends LoginBaseScreen {
  final String? phoneNumber;
  final String? title;

  PasswordSettingScreen({@required this.phoneNumber, @required this.title});

  @override
  _PasswordSettingScreenState createState() => _PasswordSettingScreenState();
}

class _PasswordSettingScreenState extends LoginBaseScreenState {
  final TextEditingController _password_controller = TextEditingController();
  final TextEditingController _confirm_controller = TextEditingController();
  bool _is_password_confirmed = false;
  String? _phoneNumber;
  String? _title;

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

  Future<void> _setPassword() async {
    if (_password_controller.text == _confirm_controller.text) {
      final t = await R2TokenStorage.getToken();
      print('Password Setting:');
      print('  get token: ${t}');

      if (null != t) {
        String? combined;
        String? hashed_combined;

        combined = '${_phoneNumber}${_password_controller.text}';
        hashed_combined = _hashPassword(combined);
        print('combined: ${combined}');
        print('hashed_combined: ${hashed_combined}');

        final response = await http.post(
          Uri.parse('http://r2cycling.imai.site/api/user/modUserPass'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'apiToken': '$t',
          },
          body: {
            'sid': '825067',
            'modPassword': hashed_combined,
          },
        );

        if (200 == response.statusCode) {
          final r = R2HttpResponse.fromJson(response.body);
          print('Password sent successfully');
          print('Success: ${r.success}');
          print('Message: ${r.message}');
          print('Code: ${r.code}');
          print('stackTracke: ${r.stackTracke}');
          print('Result: ${r.result}');
          if (true == r.success) {
            final db = R2DBHelper();
            final account = R2Account(account: _phoneNumber??'');

            db.saveAccount(account);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false,
            );
          }
        } else {
          print('Failed to set password: ${response.body}');
        }
      }
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
            child: const Text('密码至少6位，包含数字和字母\n'),
          ),
          // text field for entering phone number
          R2UserTextField(
            prefixWidget: const Text(
              '[***]',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            hintText: '输入新密码',
            controller: _password_controller,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height:20),
          // text field for entering password
          R2UserTextField(
            prefixWidget: const Text(
              '[***]',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            hintText: '再次确认',
            controller: _confirm_controller,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 30.0),
          SizedBox(height: 48.0),
        ]
    );
  }

  /*
   * it works like a toast, but it features more functionalities than toast does.
   * it seems that flash library has a real toast module, but I failed to
   * get toast working. Try it later.
   */
  void _showBasicFlash({
    Duration? duration,
    flashStyle = FlashBehavior.floating,
  }) {
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return FlashBar(
          controller: controller,
          forwardAnimationCurve: Curves.easeInCirc,
          reverseAnimationCurve: Curves.bounceIn,
          position: FlashPosition.top,
          behavior: flashStyle,
          contentTextStyle:TextStyle(fontSize: 20, color:Colors.red),
          content: Center(child:Text('两次密码输入不一致')),
        );
        },
    );
  }

  /*
  void _showSuccessFlash() {
    _showBasicFlash(message: 'Password updated successfully!', duration: Duration(seconds: 2));
  }

  void _showErrorFlash({required String message}) {
    _showBasicFlash(message: message, duration: Duration(seconds: 3));
  }
   */

  @override
  void main_button_clicked() {
    // TODO: implement main_button_clicked
    int is_same = 0;

    super.main_button_clicked();
    is_same = _password_controller.text.compareTo(_confirm_controller.text);
    print('1st:${_password_controller.text} 2nd:${_confirm_controller.text} same?${is_same}');
    if (0 == is_same) {
      _is_password_confirmed = false;
      _setPassword();
    } else {
      _showBasicFlash(duration:Duration(seconds: 3));
    }
    print('main button clicked');
  }
}