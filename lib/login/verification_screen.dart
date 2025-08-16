import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:r2cyclingapp/r2controls/r2_flash.dart';
import 'package:r2cyclingapp/r2controls/r2_loading_indicator.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

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
    // mainButtonTitle will be set in build method using localization
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /*
   * request v-code (verification code) from R2Cloud with correct phone number fed.
   */
  Future<void> _requestVcode() async {
    final isValidNumber = _isValidPhoneNumber(_phoneController.text);

    if (true == isValidNumber) {
      // loading indicator for v-code request
      R2LoadingIndicator.show(context);

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
      final request = R2HttpRequest();
      final response = await request.postRequest(
        api: 'common/sendAuthCode',
        body: {
          'sid': sid,
          'userMobile': userMobile,
        },
      );

      // start 60s countdown
      _secondsRemaining = 60;
      _startTimer();

      // stop loading indicator
      if (mounted) {
        R2LoadingIndicator.stop(context);
      }

      if (true == response.success) {
        debugPrint('$runtimeType : Verification code sent successfully');
      } else {
        debugPrint(
            '$runtimeType : Failed to request verification code: ${response
                .code}');

        if (mounted) {
          R2Flash.showBasicFlash(
            context: context,
            message: '${response.message} (${response.code})',
          );
        }
      }

    } else {
      // phone number is missing , or in a wrong format
      R2Flash.showBasicFlash(
        context: context,
        message: AppLocalizations.of(context)!.phoneNumberFormatError,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /*
   * request authorization token with phone number and v-code fed.
   */
  Future<void> _requestToken() async {
    final isValidNumber = _isValidPhoneNumber(_phoneController.text);
    final isValidCode = _isValidVerificationCode(_vcodeController.text);

    if (true == isValidNumber && true == isValidCode) {
      // start loading indicator for token request
      R2LoadingIndicator.show(context);

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
      final request = R2HttpRequest();
      final response = await request.postRequest(
        api: 'common/mobileLogin',
        body: {
          'sid': sid,
          'userMobile': phonenumber,
          'validateCode': vcode
        },
      );

      //stop indicator
      if (mounted) {
        R2LoadingIndicator.stop(context);
      }

      if (true == response.success) {
        debugPrint(
            '$runtimeType : Response of token request by phone number + password');
        debugPrint('$runtimeType :  Code: ${response.code}');
        debugPrint('$runtimeType :  result: ${response.result}');

        final token = response.result;
        final manager = R2UserManager();
        // Save the token
        manager.saveToken(token);

        onTokenRetrieved(token);
      } else {
        debugPrint('$runtimeType : Failed to request token: ${response.code}');
        if (mounted) {
          R2Flash.showBasicFlash(
              context: context,
              message: '${response.message} (${response.code})',
              duration: const Duration(seconds: 3)
          );
        }
      }
    } else {
      // v-code is in a wrong format
      if (_phoneController.text.isNotEmpty && _vcodeController.text.isNotEmpty) {
        String warning;
        if (false == isValidCode && false == isValidNumber) {
          warning = AppLocalizations.of(context)!.phoneOrCodeFormatError;
        } else if (false == isValidCode) {
          warning = AppLocalizations.of(context)!.codeFormatError;
        } else {
          warning = AppLocalizations.of(context)!.phoneFormatError;
        }
        R2Flash.showBasicFlash(
          context: context,
          message: warning,
          duration: const Duration(seconds: 3),
        );
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
          child:Text('${_secondsRemaining}s', style: const TextStyle(color: AppConstants.textColor),)
      );
    } else {
      return TextButton(
        onPressed: _requestVcode,
        child: Text(AppLocalizations.of(context)!.getVerificationCode, style: const TextStyle(color: AppConstants.textColor),),
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
      padding: const EdgeInsets.fromLTRB(25.0,0.0,25.0,0.0),
      child:Image.asset('assets/images/r2cycling_logo.png'),
    );
  }

  /*
   * Chinese phone number consists of exactly 11 digits,
   * return: true for matching, false for irregular
   */
  bool _isValidPhoneNumber(String input) {
    // Regular expression to match exactly 11 digits
    final RegExp phoneNumberPattern = RegExp(r'^\d{11}$');

    // Check if the input matches the pattern
    return phoneNumberPattern.hasMatch(input);
  }

  /*
   * verification code consists of 6 digits
   * return: true for matching, false for irregular
   */
  bool _isValidVerificationCode(String input) {
    // Regular expression to match exactly 13 digits
    final RegExp codePattern = RegExp(r'^\d{6}$');

    // Check if the input matches the pattern
    return codePattern.hasMatch(input);
  }

  /*
   * it is called after token retrieved.
   */
  void onTokenRetrieved(String token) {
    // Child classes should handle their own navigation
  }

  /*
   * two controls of text filed for entering phone number and v-code
   */
  @override
  Widget centerWidget(BuildContext context) {
    // Set the main button title using localization
    mainButtonTitle = AppLocalizations.of(context)!.registerLogin;
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
                color: AppConstants.primaryColor200,
              ),
            ),
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 40.0),
          // text field for entering password
          R2UserTextField(
            prefixWidget: Image.asset('assets/icons/icon_vcode.png', width: 24, height: 24),
            hintText: AppLocalizations.of(context)!.enterVerificationCode,
            suffixWidget: _vcodeButton(),
            controller: _vcodeController,
            keyboardType: TextInputType.number,
          ),
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