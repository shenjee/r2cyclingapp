import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:r2cyclingapp/r2controls/r2_flash.dart';
import 'package:r2cyclingapp/r2controls/r2_loading_indicator.dart';
import 'package:r2cyclingapp/usermanager/r2_group.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';

import 'group_intercom_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final _textEditingController = TextEditingController();
  final _errorController = StreamController<ErrorAnimationType>();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _requestJoinGroup(String? group) async {
    // show loading indicator for requesting
    R2LoadingIndicator.show(context);

    final manager = R2UserManager();
    final token = await manager.readToken();
    final request = R2HttpRequest();
    final response = await request.postRequest(
      token: token,
      api: 'cyclingGroup/joinGroup',
      body: {
        'joinCode':'$group',
      }
    );

    // stop the indicator
    if (mounted) {
      R2LoadingIndicator.stop(context);
    }

    if (true == response.success && group != null) {
      debugPrint('$runtimeType : Request succeeded: ${response.message}');
      debugPrint('$runtimeType :   Response code: ${response.code}');
      debugPrint('$runtimeType :   Result: ${response.result}');

      final account = await manager.localAccount();
      final gid = response.result['cyclingGroupId'];
      final gName = response.result['groupName'];
      final group = R2Group(gid: gid);
      final ret = await manager.saveGroup(account!.uid, group);
      debugPrint('$runtimeType : save group $gid : $ret');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GroupIntercomScreen()),
        );
      }
    } else {
      debugPrint('Failed to join group: ${response.code}');
      // should show error info
      String warning = '${response.message}（${response.code}）';
      if (mounted) {
        R2Flash.showBasicFlash(
          context: context,
          message: warning,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('加入一个骑行组'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 10.0),
            child: Text('输入四位组编号', style: TextStyle(fontSize: 18.0),),
          ),
          Padding (
            padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
            child: PinCodeTextField(
              appContext: context,
              length: 4,
              obscureText: false,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              textStyle: const TextStyle(fontSize: 24.0),
              cursorColor: Colors.grey,
              autoFocus:true,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                fieldHeight: 80,
                fieldWidth: 60,
                inactiveBorderWidth: 1.0,
                inactiveColor: Colors.grey,
                inactiveFillColor:Colors.white,
                activeBorderWidth: 1.0,
                activeColor: const Color(0xFF539765),
                activeFillColor: Colors.white,
                selectedBorderWidth: 1.0,
                selectedColor: Colors.grey,
                selectedFillColor: Colors.white,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              errorAnimationController: _errorController,
              controller: _textEditingController,
              onCompleted: (value) {
                debugPrint('$runtimeType : Completed $value');
                _requestJoinGroup(value);
                },
              onChanged: (value) {
                debugPrint(value);
                },
              beforeTextPaste: (text) {
                debugPrint("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                // but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),
          ),
        ],
      ),
    );
  }
}