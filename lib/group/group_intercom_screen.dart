import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/database/r2_token_storage.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_account.dart';

class GroupIntercomScreen extends StatefulWidget {
  const GroupIntercomScreen({super.key});

  @override
  _GroupIntercomScreenState createState() => _GroupIntercomScreenState();
}

class _GroupIntercomScreenState extends State<GroupIntercomScreen> {
  String? _groupCode;
  final List<R2Account> _members = [];
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
    _requestGroupCode();
  }

  void _loadLocalUser() async {
    final db = R2DBHelper();
    final account = await db.getLocalAccount();
    if (account != null && _members.length < 8) {
      setState(() {
        _members.add(account);
      });
    }
  }

  void _decodeMemberList(Map<String, dynamic> result) {
    List<dynamic> mlist = result['memberList']; // 获取memberList字段
    final account = _members.first;

    for (var memberData in mlist) {
      if (memberData['loginId'] != account.account) {
        R2Account account = R2Account(
            account: memberData['userMobile'] ?? memberData['loginId'])
          ..nickname = memberData['userName'] ?? 'Unknown'
          ..avatarPath = memberData['userAvatar'] ?? ''; // 使用默认值或null

        // 添加到成员列表
        if (_members.length < 8) {
          setState(() {
            _members.add(account);
          });
        }
      }
    }
  }

  void _requestGroupCode() async {
    final token = await R2TokenStorage.getToken();
    final r2request = R2HttpRequest();
    final r2response = await r2request.sendRequest(
      token: token,
      api: 'cyclingGroup/getMyGroup',
    );

    if (true == r2response.success) {
      print('Request succeeded: ${r2response.message}');
      print('Response code: ${r2response.code}');
      print('Result: ${r2response.result}');

      Map<String, dynamic> resultData = r2response.result;
      int groupNum = resultData['groupNum'];
      String formattedString = groupNum.toString().padLeft(4, '0'); // Convert to 4-digit string
      print('Formatted Result: $formattedString');
      setState(() {
        _groupCode = formattedString;
      });
      _decodeMemberList(resultData);
    } else {
      print('Failed to request group code: ${r2response.code}');
    }
  }

  void _leaveGroup() async {
    final token = await R2TokenStorage.getToken();
    final r2request = R2HttpRequest();
    final r2response = await r2request.sendRequest(
      token: token,
      api: 'cyclingGroup/leaveGroup',
    );

    if (true == r2response.success) {
      print('Request succeeded: ${r2response.message}');
      print('Response code: ${r2response.code}');
      print('Result: ${r2response.result}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('groupNumber');
      Navigator.of(context).pop();
    } else {
      print('Failed to request group code: $r2response');
    }
  }

  void _onIntercomTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onIntercomTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    // 在此处添加启动或停止对讲的逻辑
    print("Intercom button tapped");
  }

  void _onIntercomTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

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
    );
  }

  Widget _intercomButton() {
    return GestureDetector(
      onTapDown: _onIntercomTapDown,
      onTapUp: _onIntercomTapUp,
      onTapCancel: _onIntercomTapCancel,
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.greenAccent, width: 4),
          boxShadow: _isPressed
              ? const [BoxShadow(color: Colors.grey, blurRadius: 10, offset: Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(
            _isPressed ? '正在对讲' : '',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('骑行对讲'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'quit') {
                _leaveGroup();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'quit',
                  child: Text('退出骑行组', style: TextStyle(color: Colors.white)),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
            color: Colors.black, // 菜单背景设置为黑色
          ),
        ],
      ),
      body: Column (
        children: <Widget>[
          Center(child: _groupNumberWidget(context),),
          _groupMemberWidget(context),
          const SizedBox(height: 20),
          _intercomButton(),
        ],
      ),
    );
  }
}
