import 'package:flutter/material.dart';

import 'package:r2cyclingapp/r2controls/r2_flash.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/usermanager/r2_account.dart';


import 'group_intercom_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  String? _groupCode;
  final List<R2Account> _members = [];

  @override
  void initState() {
    super.initState();
    _requestGroupCode();
    _loadLocalUser();
  }

  void _loadLocalUser() async {
    final manager = R2UserManager();
    final account = await manager.localAccount();
    if (account != null && _members.length < 8) {
      setState(() {
        _members.add(account);
      });
    }
  }

  /*
   * request a group pin code, so that others can join the group by the code
   */
  void _requestGroupCode() async {
    final token = await R2Storage.getToken();
    final request = R2HttpRequest();
    final response = await request.postRequest(
        token: token,
        api: 'cyclingGroup/newGroup',
    );

    if (true == response.success) {
      debugPrint('Request succeeded: ${response.message}');
      debugPrint('Response code: ${response.code}');
      debugPrint('Result: ${response.result}');

      Map<String, dynamic> resultData = response.result;
      int groupNum = resultData['groupNum'];
      String formattedString = groupNum.toString().padLeft(4, '0'); // Convert to 4-digit string
      debugPrint('Formatted Result: $formattedString');
      setState(() {
        _groupCode = formattedString;
      });
    } else {
      debugPrint('Failed to request group code: $response');
      if (mounted) {
        R2Flash.showBasicFlash(
          context: context,
          message: '${response.message} (${response.code})',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /*
   * during the creation, the creator doesn't want to join it and leave.
   */
  void _leaveGroup() async {
    final token = await R2Storage.getToken();
    final r2request = R2HttpRequest();
    final r2response = await r2request.postRequest(
      token: token,
      api: 'cyclingGroup/leaveGroup',
    );

    if (true == r2response.success) {
      debugPrint('Request succeeded: ${r2response.message}');
      debugPrint('Response code: ${r2response.code}');
      debugPrint('Result: ${r2response.result}');
    } else {
      debugPrint('Failed to request group code: $r2response');
    }
  }

  /*
   * show the group pin code (group number)
   */
  Widget _groupNumberWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 20.0,),
        const Text('让身边的骑友输入下方四位编号，'),
        const Text('加入同一个骑行组，'),
        const SizedBox(height: 20.0,),
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _groupCode??'- - - -',
                    style: const TextStyle(
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF539765),
                    ),
                  ),
                ]
            ),
            const Positioned(
              left:  80,
              child: Text('组编号：'),
            ),
          ],
        )
      ],
    );
  }

  Widget _groupMemberWidget(BuildContext context) {
    return GridView.builder (
      shrinkWrap: true, // 在Column中使用时，确保GridView不会扩展以占据整个空间
      physics: const NeverScrollableScrollPhysics(), // 禁用GridView滚动，避免与外部滚动冲突
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 每行4个成员
        childAspectRatio: 1, // 正方形的子项
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member  = _members[index];
        return Column(
          children: [
            FutureBuilder<Image>(
              future: member.getAvatar(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 30,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.error),
                  );
                } else {
                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: snapshot.data?.image,
                  );
                }
              },
            ),
            const SizedBox(height: 5),
            Text(member.nickname),
          ],
        );
      },
    );  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('建立一个骑行组'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _leaveGroup();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column (
        children: <Widget>[
          Center(child: _groupNumberWidget(context),),
          _groupMemberWidget(context),
          ElevatedButton(
            onPressed: () {
              // Save the group to the database and navigate to GroupIntercomScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const GroupIntercomScreen()),
              );
              },
            child: const Text('Start Group Intercom'),
          ),
        ],
      ),
    );
  }
}
