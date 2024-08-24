import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/usermanager/r2_account.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/intercom/r2_intercom_engine.dart';

class GroupIntercomScreen extends StatefulWidget {
  const GroupIntercomScreen({super.key});

  @override
  State<GroupIntercomScreen> createState() => _GroupIntercomScreenState();
}

class _GroupIntercomScreenState extends State<GroupIntercomScreen> {
  int? _groupID;
  int? _userID;
  String? _groupCode;
  final List<R2Account> _members = [];
  bool _isPressed = false;
  R2IntercomEngine? _r2intercom;
  final _manager = R2UserManager();

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
    _requestMyGroup();
  }

  _initR2Intercom() {
    final account = _members.first;
    _r2intercom = R2IntercomEngine(groupID: _groupID!, userID:account.uid);
    _r2intercom!.initAgora();
  }

  /*
   * load local user and put it to the intercom member list
   *  as the leading role.
   */
  void _loadLocalUser() async {
    final account = await _manager.localAccount();
    if (account != null && _members.length < 8) {
      setState(() {
        _members.add(account);
      });
    }
  }

  /*
   * decode the response of group to build the member list
   *
   * result:
   */
  void _decodeMemberList(Map<String, dynamic> result) {
    List<dynamic> mlist = result['memberList'];
    final account = _members.first;

    for (var memberData in mlist) {
      if (memberData['loginId'] != account.account) {
        R2Account account = R2Account(
            uid: memberData['id'] ?? memberData['userId'],
            account: memberData['userMobile'] ?? memberData['loginId'])
          ..nickname = memberData['userName'] ?? 'Unknown'
          ..avatarPath = memberData['userAvatar'] ?? ''; // 使用默认值或null

        // add to member list
        if (_members.length < 8) {
          setState(() {
            _members.add(account);
          });
        }
      }
    }
  }

  /*
   * request the group which the local user has joined,
   * including group number, name and members.
   */
  Future<void> _requestMyGroup() async {
    final token = await _manager.readToken();
    final r2request = R2HttpRequest();
    final r2response = await r2request.postRequest(
      token: token,
      api: 'cyclingGroup/getMyGroup',
    );

    if (true == r2response.success) {
      debugPrint('Request succeeded: ${r2response.message}');
      debugPrint('Response code: ${r2response.code}');
      debugPrint('Result: ${r2response.result}');

      Map<String, dynamic> resultData = r2response.result;
      int groupNum = resultData['groupNum'];
      _groupID = resultData['id'];
      _userID = resultData['userId'];
      String formattedString = groupNum.toString().padLeft(4, '0'); // Convert to 4-digit string
      debugPrint('Formatted Result: $formattedString');
      setState(() {
        _groupCode = formattedString;
      });
      _decodeMemberList(resultData);
      _initR2Intercom();
    } else {
      debugPrint('Failed to request my group: ${r2response.code}');
    }
  }

  void _leaveMyGroup() async {
    final token = await _manager.readToken();
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
      debugPrint('Failed to leave group code: ${r2response.code}');
    }
  }

  /*
   * callback of rtc engine,
   * handle tasks right after local user is a member of rtc group.
   * uid: local user id allocated by Agora
   */
  void _onLocalJoined(int uid) {
    // TODO: implementation
  }

  /*
   * handle tasks right after a member entering rtc group.
   * uid: user id allocated by Agora
   */
  void _onMemberJoined(int uid) {
    // TODO: implementation
  }

  /*
   * callback of rtc engine,
   * handle tasks right after a member leaving rtc group.
   * uid: user id allocated by Agora
   */
  void _onMemberLeft(int uid) {
    // TODO: implementation
  }

  /*
   * callback responds to down tapped intercom button
   */
  void _onIntercomTapDown(TapDownDetails details) {
    debugPrint('$runtimeType: _isPressed $_isPressed');
    if (false == _isPressed) {
      _r2intercom!.pauseSpeak(false);
    }
    setState(() {
      _isPressed = true;
    });
  }

  /*
   * callback responds to released intercom button
   */
  void _onIntercomTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
      _r2intercom!.pauseSpeak(true);
    });
    // 在此处添加启动或停止对讲的逻辑
    debugPrint("$runtimeType: Intercom button tapped");
  }

  /*
   * callback responds to stop tapping intercom button
   */
  void _onIntercomTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _r2intercom!.stopIntercom();
  }

  /*
   * show the number of the intercom group.
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

  /*
   * show the members of the intercom group.
   * there are no more than 8 members and organized in two rows,
   * 4 members per row.
   * an avatar and a nickname of user represents him/her.
   */
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

  /*
   * a rounded button that start intercom when it is tapped down.
   */
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
            _r2intercom!.stopIntercom();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'quit') {
                _leaveMyGroup();
                _r2intercom!.stopIntercom();
                Navigator.of(context).pop();
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