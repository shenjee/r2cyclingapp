// Copyright (c) 2025 RockRoad Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:r2cyclingapp/r2controls/r2_flash.dart';
import 'package:r2cyclingapp/r2controls/r2_loading_indicator.dart';
import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/auth/auth_service.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

import 'login_base_screen.dart';

class VerificationScreen extends LoginBaseScreen {
  const VerificationScreen({super.key});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends LoginBaseScreenState {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vcodeController = TextEditingController();
  bool _isVcodeRequested = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // mainButtonTitle will be set in build method using localization
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainButtonTitle = AppLocalizations.of(context)!.registerLogin;
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
    final isValidNumber = _isValidPhoneNumber(phoneController.text);

    if (true == isValidNumber) {
      // loading indicator for v-code request
      R2LoadingIndicator.show(context);

      final String userMobile = phoneController.text;
      final auth = AuthService();
      final resp = await auth.sendAuthCode(phone: userMobile);

      // start 60s countdown
      _secondsRemaining = 60;
      _startTimer();

      // stop loading indicator
      if (mounted) {
        R2LoadingIndicator.stop(context);
      }

      if (resp.success) {
        debugPrint('$runtimeType : Verification code sent successfully');
      } else {
        if (mounted) {
          R2Flash.showBasicFlash(
            context: context,
            message: (resp.message ?? 'Request failed').toString(),
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
    final isValidNumber = _isValidPhoneNumber(phoneController.text);
    final isValidCode = _isValidVerificationCode(vcodeController.text);

    if (true == isValidNumber && true == isValidCode) {
      // start loading indicator for token request
      R2LoadingIndicator.show(context);

      // get phone number and v-code
      final String phonenumber = phoneController.text;
      final String vcode = vcodeController.text;
      final auth = AuthService();
      final resp = await auth.loginWithCode(phone: phonenumber, code: vcode);

      //stop indicator
      if (mounted) {
        R2LoadingIndicator.stop(context);
      }

      if (resp.success && (resp.result ?? '').isNotEmpty) {
        final String token = resp.result!;
        onTokenRetrieved(token);
      } else {
        if (mounted) {
          R2Flash.showBasicFlash(
              context: context,
              message: (resp.message ?? 'Request failed').toString(),
              duration: const Duration(seconds: 3));
        }
      }
    } else {
      // v-code is in a wrong format
      if (phoneController.text.isNotEmpty && vcodeController.text.isNotEmpty) {
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
          child: Text(
            '${_secondsRemaining}s',
            style: const TextStyle(color: AppConstants.textColor),
          ));
    } else {
      return TextButton(
        onPressed: _requestVcode,
        child: Text(
          AppLocalizations.of(context)!.getVerificationCode,
          style: const TextStyle(color: AppConstants.textColor),
        ),
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
      padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
      child: Image.asset('assets/images/r2cycling_logo.png'),
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
    //mainButtonTitle = AppLocalizations.of(context)!.registerLogin;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // text field for entering phone number
          R2UserTextField(
            prefixWidget: const Text(
              '+86',
              style: TextStyle(
                fontSize: 20,
                color: AppConstants.primaryColor200,
              ),
            ),
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 40.0),
          // text field for entering password
          R2UserTextField(
            prefixWidget: Image.asset('assets/icons/icon_vcode.png',
                width: 24, height: 24),
            hintText: AppLocalizations.of(context)!.enterVerificationCode,
            suffixWidget: _vcodeButton(),
            controller: vcodeController,
            keyboardType: TextInputType.number,
          ),
        ]);
  }

  /*
   * register and login
   */
  @override
  void mainButtonClicked() {
    _requestToken();
  }
}
