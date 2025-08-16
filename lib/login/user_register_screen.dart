import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:r2cyclingapp/constants.dart';

import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/usermanager/r2_account.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';

import 'verification_screen.dart';
import 'user_login_screen.dart';
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
                  Text(
                    AppLocalizations.of(context)!.agreeTermsAndPrivacy,
                    style: const TextStyle(color: Colors.black),
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