import 'package:flutter/material.dart';
import 'package:flash/flash.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:r2cyclingapp/database/r2_account.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
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
    if (_passwordController.text == _confirmController.text) {
      // get uuid as session id
      final prefs = await SharedPreferences.getInstance();
      String? sid = prefs.getString('sessionId');
      if (null == sid) {
        var uuid = const Uuid();
        sid = uuid.v4();
        await prefs.setString('sessionId', sid);
      }

      final t = await R2TokenStorage.getToken();
      print('Password Setting:');
      print('  get token: $t');

      if (null != t) {
        String? combined;
        String? hashed_combined;

        combined = '${_phoneNumber}${_passwordController.text}';
        hashed_combined = _hashPassword(combined);
        print('combined: $combined');
        print('hashed_combined: $hashed_combined');

        final request = R2HttpRequest();
        final response = await request.sendRequest(
          api: 'user/modUserPass',
          token: t,
          body: {
            'sid': sid,
            'modPassword': hashed_combined,
          },
        );

        if (true == response.success) {
          print('Password sent successfully');
          print('Message: ${response.message}');
          print('Code: ${response.code}');
          print('Result: ${response.result}');

          final db = R2DBHelper();
          final account = R2Account(account: _phoneNumber??'');
          db.saveAccount(account);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false,
          );
        } else {
          print('Failed to set password: ${response.code}');
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
            controller: _passwordController,
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
            controller: _confirmController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 30.0),
          const SizedBox(height: 48.0),
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
    is_same = _passwordController.text.compareTo(_confirmController.text);
    print('1st:${_passwordController.text} 2nd:${_confirmController.text} same?${is_same}');
    if (0 == is_same) {
      _setPassword();
    } else {
      _showBasicFlash(duration:const Duration(seconds: 3));
    }
    print('main button clicked');
  }
}