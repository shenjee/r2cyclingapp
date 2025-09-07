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

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:r2cyclingapp/constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';

import 'verification_screen.dart';
import 'password_setting_screen.dart';

class UserRegisterScreen extends VerificationScreen {
  const UserRegisterScreen({super.key});

  @override
  VerificationScreenState createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends VerificationScreenState {
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    // mainButtonTitle will be set in didChangeDependencies
  }
  
  // Build the clickable text spans for Terms of Service and Privacy Policy
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
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _TermsPrivacyScreen(content: content, title: title),
          ),
        );
      }
    } catch (e) {
      print('Error loading $fileName: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainButtonTitle = AppLocalizations.of(context)!.registerLogin;
  }

  /*
   * Customize the leading button of app bar, making it pop off
   * when it is tapped.
   */
  @override
  PreferredSizeWidget widgetAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, size: 34.0,),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
          super.centerWidget(context),
          const SizedBox(height: 30.0),
          Container (
            width: 340,
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(AppLocalizations.of(context)!.passwordLogin,
                style: const TextStyle(color: AppConstants.textColor),
              ),
            ),
          ),
        ]
    );
  }

  /*
   * in the bottom, there is a note for these users who is not member of R2
   */
  @override
  Widget bottomWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top aligned text
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              AppLocalizations.of(context)!.unregisteredPhoneAutoCreate,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0, color: AppConstants.textColor),
            ),
          ),
        ),
        // Bottom aligned checkbox with text
        Align(
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
      ],
    );
  }

  @override
  void onTokenRetrieved(String token) async {
    final manager = R2UserManager();
    
    await manager.requestUserProfile();

    final account = await manager.localAccount();
    if (account != null) {
      final needSetPassword = !account.isPasswdSet;
      
      if (needSetPassword) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              PasswordSettingScreen(
                phoneNumber: account.phoneNumber,
                title: AppLocalizations.of(context)!.setPassword,
              )
          ),
        );
      } else {
         if (mounted) {
           Navigator.of(context).pop();
         }
       }
     }
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