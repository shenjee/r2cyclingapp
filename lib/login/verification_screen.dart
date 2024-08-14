import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/connection/http/r2_http_response.dart';
import 'package:r2cyclingapp/database/r2_token_storage.dart';

import 'login_base_screen.dart';

class VerificationScreen extends LoginBaseScreen {
  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends LoginBaseScreenState {
  // uuid of http service, named after ASCII of R2C which is 82 50 67
  final String sid = '825067';

  final TextEditingController _phone_controller = TextEditingController();
  final TextEditingController _vcode_controller = TextEditingController();
  bool _is_code_requested = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    mainButtonTitle = '注册/登录';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /*
   * it is called after token retrieved and handled.
   * there are two values of the response, one is token, the other is bool value
   * which indicates the user is a new register and must set the password.
   */
  void is_token_handled(String phone_number, bool void_password) {
    // TODO: implementaion
  }

  /*
   * request v-code (verification code) from R2Cloud with correct phone number fed.
   */
  Future<void> _request_vcode() async {
    // request code via http
    final String userMobile = _phone_controller.text;

    final response = await http.post(
      Uri.parse('http://r2cycling.imai.site/api/common/sendAuthCode'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'sid': sid,
        'userMobile': userMobile,
      },
    );

    // start 60s countdown
    _secondsRemaining = 60;
    _startTimer();

    if (200 == response.statusCode) {
      final r = R2HttpResponse.fromJson(response.body);
      print('Verification code sent successfully');
      print('Success: ${r.success}');
      print('Message: ${r.message}');
      print('Code: ${r.code}');
      print('stackTracke: ${r.stackTracke}');
      print('Result: ${r.result}');
    } else {
      print('Failed to send verification code: ${response.body}');
    }
  }

  /*
   * request authorization token with phone number and v-code fed.
   */
  Future<void> _request_token() async {
    final String phonenumber = _phone_controller.text;
    final String vcode = _vcode_controller.text;

    final response = await http.post(
      Uri.parse('http://r2cycling.imai.site/api/common/mobileLogin'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'sid': sid,
        'userMobile': phonenumber,
        'validateCode': vcode
      },
    );

    if (200 == response.statusCode) {
      final r = R2HttpResponse.fromJson(response.body);
      print('Response of token request by phonenumber + password');
      print('  Success: ${r.success}');
      print('  Message: ${r.message}');
      print('  Code: ${r.code}');
      print('  stackTracke: ${r.stackTracke}');
      print('  result: ${r.result}');
      if (true == r.success && 200 == r.code) {
        // retrieve the token and password-setting indicator
        final Map<String, dynamic> data = r.result;
        final token = data['token'];
        final need_set_passwd = data['defaultPassword'];
        print('  Parse result');
        print('    token: ${token}');
        print('    need_set_passwd: ${need_set_passwd}');

        await R2TokenStorage.saveToken(token);

        is_token_handled(phonenumber,need_set_passwd);
      }
    } else if (500 == response.statusCode) {
      print('verification code expired: ${response.body}');
    } else {
      print('Failed to send verification code: ${response.body}');
      Navigator.of(context).pop();
    }
  }

  /*
   * button for request v-code with phone number fed
   * once it is tapped and v-code received, it starts timer for 60s countdown
   */
  Widget _request_vcode_button() {
    if (true == _is_code_requested) {
      return Text('${_secondsRemaining}s');
    } else {
      return TextButton(
        child: Text('获取验证码'),
        onPressed: _request_vcode,
      );
    }
  }

  /*
   * it starts a countdown time for <_secondsRemaining> seconds .
   * e.g. "_secondsRemaining = 6" starts a 60 seconds countdown.
   */
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          _is_code_requested = true;
        } else {
          _timer?.cancel();
          _is_code_requested = false;
          print("timer finished ${_secondsRemaining}");
        }
      });
    });
  }

  @override
  Widget topWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40.0),
      child:Image.asset('assets/images/r2cycling_logo.png')
    );
  }

  /*
   * two controls of text filed for entering phone number and v-code
   */
  @override
  Widget centerWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
          SizedBox(height: 20),
          // text field for entering password
          R2UserTextField(
            prefixWidget: Text(
              '[•••]',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            hintText: '请输入验证码',
            suffixWidget: _request_vcode_button(),
            controller: _vcode_controller,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 30),
        ]
    );
  }

  /*
   * register and login
   */
  @override
  void main_button_clicked() {
    // TODO: override
    _request_token();
  }
}