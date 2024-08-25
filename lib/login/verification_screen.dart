import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';

import 'login_base_screen.dart';

class VerificationScreen extends LoginBaseScreen {
  const VerificationScreen({super.key});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends LoginBaseScreenState {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vcodeController = TextEditingController();
  bool _isVcodeRequested = false;
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
  void onTokenHandled(String token, String account, bool needSetPassword) {
    // save the account
    final manager = R2UserManager();
    manager.saveToken(token);
    manager.saveAccountWithToken(token);
    manager.requestUserProfile();
    // TODO: implementaion
  }

  /*
   * request v-code (verification code) from R2Cloud with correct phone number fed.
   */
  Future<void> _requestVcode() async {
    // get uuid as session id
    final prefs = await SharedPreferences.getInstance();
    String? sid = prefs.getString('sessionId');
    if (null == sid) {
      var uuid = const Uuid();
      sid = uuid.v4();
      await prefs.setString('sessionId', sid);
    }

    // request code via http
    final String userMobile = _phoneController.text;
    final r2request = R2HttpRequest();
    final r2response = await r2request.postRequest(
      api: 'common/sendAuthCode',
      body: {
        'sid': sid,
        'userMobile': userMobile,
      },
    );

    // start 60s countdown
    _secondsRemaining = 60;
    _startTimer();

    if (true == r2response.success) {
      debugPrint('$runtimeType : Verification code sent successfully');
    } else {
      debugPrint('$runtimeType : Failed to request verification code: ${r2response.code}');
    }
  }

  /*
   * request authorization token with phone number and v-code fed.
   */
  Future<void> _requestToken() async {
    // get uuid
    final prefs = await SharedPreferences.getInstance();
    String? sid = prefs.getString('sessionId');
    if (null == sid) {
      var uuid = const Uuid();
      sid = uuid.v4();
      await prefs.setString('sessionId', sid);
    }
    // get phone number and v-code
    final String phonenumber = _phoneController.text;
    final String vcode = _vcodeController.text;
    final r2request = R2HttpRequest();
    final r2response = await r2request.postRequest(
      api: 'common/r2mobileLogin',
      body: {
        'sid': sid,
        'userMobile': phonenumber,
        'validateCode': vcode
      },
    );

    if (true == r2response.success) {
      debugPrint('$runtimeType : Response of token request by phonenumber + password');
      debugPrint('$runtimeType :  Message: ${r2response.message}');
      debugPrint('$runtimeType :  Code: ${r2response.code}');
      debugPrint('$runtimeType :  result: ${r2response.result}');

      final Map<String, dynamic> data = r2response.result;
      final token = data['token'];
      final setPassword = data['defaultPassword'];

      onTokenHandled(token, phonenumber, setPassword);
    } else {
      debugPrint('$runtimeType : Failed to request token: ${r2response.code}');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  /*
   * button for request v-code with phone number fed
   * once it is tapped and v-code received, it starts timer for 60s countdown
   */
  Widget _vcodeButton() {
    if (true == _isVcodeRequested) {
      return Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0, 20.0, 0.0),
          child:Text('${_secondsRemaining}s', style: const TextStyle(color: Colors.grey),)
      );
    } else {
      return TextButton(
        onPressed: _requestVcode,
        child: const Text('获取验证码'),
      );
    }
  }

  /*
   * it starts a countdown time for <_secondsRemaining> seconds .
   * e.g. "_secondsRemaining = 6" starts a 60 seconds countdown.
   */
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          _isVcodeRequested = true;
        } else {
          _timer?.cancel();
          _isVcodeRequested = false;
          debugPrint("$runtimeType : timer finished $_secondsRemaining");
        }
      });
    });
  }

  @override
  Widget topWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
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
          const SizedBox(height: 20),
          // text field for entering password
          R2UserTextField(
            prefixWidget: const Icon(Icons.key, color:Colors.grey),
            hintText: '请输入验证码',
            suffixWidget: _vcodeButton(),
            controller: _vcodeController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 30),
        ]
    );
  }

  /*
   * register and login
   */
  @override
  void mainButtonClicked() {
    // TODO: override
    _requestToken();
  }
}