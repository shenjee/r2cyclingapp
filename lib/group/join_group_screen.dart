import 'package:flutter/material.dart';
import 'package:r2cyclingapp/usermanager/r2_group.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _requestJoinGroup(String? group) async {
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
      // should let the user know the error with a dialog
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 60,
                height: 80,
                child: TextField(
                  controller: _controllers[index],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24.0),
                  showCursor: false,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      borderSide: const BorderSide(color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 3) {
                      FocusScope.of(context).nextFocus(); // 自动跳到下一个输入框
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus(); // 清空时自动跳到前一个输入框
                    }

                    if (value.isNotEmpty && index == 3) {
                      String groupCode = _controllers.map((controller) => controller.text).join();
                      _requestJoinGroup(groupCode);
                    }
                    },
                  autofocus: index == 0,
                ),
                );
              }),
            ),
          ],
        ),
    );
  }
}