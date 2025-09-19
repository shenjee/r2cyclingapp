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

import 'dart:convert';
import 'dart:core';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:r2cyclingapp/login/password_recover_screen.dart';

import 'package:r2cyclingapp/r2controls/r2_user_text_field.dart';
import 'package:r2cyclingapp/r2controls/r2_flash.dart';
import 'package:r2cyclingapp/r2controls/r2_loading_indicator.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

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
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    // mainButtonTitle will be set in build method using localization
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainButtonTitle = AppLocalizations.of(context)!.login;
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
      // show the loading indicator
      R2LoadingIndicator.show(context);

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
        api: 'common/passwordLogin',
        body: {
          'sid': sid,
          'loginId': phonenumber,
          'userPsw': hashedCombined,
          'validateCode': ''
        },
      );

      // stop loading indicator
      if (mounted) {
        R2LoadingIndicator.stop(context);
      }

      if (true == response.success) {
        debugPrint('Login by phone number + password');
        debugPrint('  Message: ${response.message}');
        debugPrint('  Code: ${response.code}');
        debugPrint('  Result: ${response.result}');

        // retrieve the token and password-setting indicator
        final token = response.result;

        final manager = R2UserManager();
        await manager.saveToken(token);
        await manager.requestUserProfile();

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
        String warning = '${response.message}（${response.code}）';
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
          warning = AppLocalizations.of(context)!.phonePasswordFormatError;
        } else if (false == isValidPasswd) {
          warning = AppLocalizations.of(context)!.passwordFormatError;
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

  @override
  Widget topWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0,0.0,25.0,0.0),
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
                color: AppConstants.primaryColor200,
            ),
          ),
          hintText: AppLocalizations.of(context)!.enterPhoneNumber,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height:40.0),
        // text field for entering password
        R2UserTextField(
          prefixWidget: Image.asset('assets/icons/icon_password.png', width: 24, height: 24),
          hintText: AppLocalizations.of(context)!.enterPassword,
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
        const SizedBox(height:30),
        Container (
          width: 340,
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              },
            child: Text(
              AppLocalizations.of(context)!.verificationCodeLogin, 
              style: const TextStyle(color: AppConstants.textColor),
              ),
          ),
        )
      ]
    );
  }

  /*
   * Build the clickable text spans for Terms of Service and Privacy Policy
   */
  Widget _buildTermsAndPrivacyText(BuildContext context) {
    final String fullText = AppLocalizations.of(context)!.agreeTermsAndPrivacy;
    final String termsText = AppLocalizations.of(context)!.termsOfService;
    final String privacyText = AppLocalizations.of(context)!.privacyPolicy;
    
    // Find the positions of the terms and privacy text in the full text
    final int termsIndex = fullText.indexOf(termsText);
    final int privacyIndex = fullText.indexOf(privacyText);
    
    if (termsIndex == -1 || privacyIndex == -1) {
      // If we can't find the exact text, just return the full text
      return AutoSizeText(
        fullText,
        minFontSize: 10.0,
        maxFontSize: 16.0,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    // Create the rich text with clickable links
    final richText = TextSpan(
      style: const TextStyle(color: Colors.black),
      children: [
        TextSpan(text: fullText.substring(0, termsIndex)),
        TextSpan(
          text: termsText,
          style: const TextStyle(
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _showTermsOrPrivacy(
                context, 
                Localizations.localeOf(context).languageCode == 'zh' ? 'TermsofService-zh.md' : 'TermsofService.md',
                AppLocalizations.of(context)!.termsOfService
              );
            },
        ),
        TextSpan(text: fullText.substring(termsIndex + termsText.length, privacyIndex)),
        TextSpan(
          text: privacyText,
          style: const TextStyle(
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _showTermsOrPrivacy(
                context, 
                Localizations.localeOf(context).languageCode == 'zh' ? 'PrivacyPolicy-zh.md' : 'PrivacyPolicy.md',
                AppLocalizations.of(context)!.privacyPolicy
              );
            },
        ),
        TextSpan(text: fullText.substring(privacyIndex + privacyText.length)),
      ],
    );

    return AutoSizeText.rich(
      richText,
      minFontSize: 10.0,
      maxFontSize: 16.0,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Show the Terms of Service or Privacy Policy in a full screen dialog
  void _showTermsOrPrivacy(BuildContext context, String fileName, String title) async {
    try {
      // Load the file from assets
      final String content = await DefaultAssetBundle.of(context).loadString(fileName);
      
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _TermsPrivacyScreen(content: content, title: title),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading $fileName: $e');
    }
  }

  @override
  void mainButtonClicked() {
    if (_isAgreed) {
      debugPrint('$runtimeType : main button clicked');
      _requestLogin();
    } else {
      // Show a message if user hasn't agreed to terms
      R2Flash.showBasicFlash(
        context: context,
        message: AppLocalizations.of(context)!.agreeTermsAndPrivacy,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget bottomWidget(BuildContext context) {
    return Column(
      children: [
        Container (
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
              child: Text(
                AppLocalizations.of(context)!.forgotPassword, 
                style: const TextStyle(color: AppConstants.textColor),
                ),
            )
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAgreed = !_isAgreed;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                        color: _isAgreed ? Colors.grey : Colors.transparent,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: _isAgreed ? Colors.white : Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTermsAndPrivacyText(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Screen to display Terms of Service or Privacy Policy
class _TermsPrivacyScreen extends StatelessWidget {
  final String content;
  final String title;

  const _TermsPrivacyScreen({required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Markdown(
              data: content,
              padding: const EdgeInsets.all(16.0),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}