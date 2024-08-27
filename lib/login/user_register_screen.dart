import 'package:flutter/material.dart';

import 'verification_screen.dart';
import 'user_login_screen.dart';
import 'password_setting_screen.dart';

class UserRegisterScreen extends VerificationScreen {
  const UserRegisterScreen({super.key});

  @override
  VerificationScreenState createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends VerificationScreenState {
  @override
  void initState() {
    super.initState();
    mainButtonTitle = '注册/登录';
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
   * in the top of this widget is a R2 cycling logo
   */
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
          super.centerWidget(context),
          const SizedBox(height: 30),
          Container (
            width: 340,
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                );
              },
              child: const Text('密码登录'),
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
    return const Align(
      alignment: Alignment.bottomCenter,
      child: Text('未注册的手机号验证后自动创建R2账户\n\n'),
    );
  }

  @override
  void onTokenHandled(String token, String account, bool needSetPassword) {
    super.onTokenHandled(token, account, needSetPassword);
    if (true == needSetPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            PasswordSettingScreen(
              phoneNumber: account, title: '设置密码',)),
      );
    }
  }
}