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

import 'package:r2cyclingapp/constants.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/r2controls/r2_flash.dart';
import 'package:r2cyclingapp/r2controls/r2_loading_indicator.dart';
import 'package:r2cyclingapp/connection/http/openapi/common_api.dart';
import 'package:r2cyclingapp/usermanager/r2_account.dart';
import 'package:r2cyclingapp/usermanager/r2_group.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/intercom/r2_intercom_engine.dart';

class GroupIntercomScreen extends StatefulWidget {
  const GroupIntercomScreen({super.key});

  @override
  State<GroupIntercomScreen> createState() => _GroupIntercomScreenState();
}

class _GroupIntercomScreenState extends State<GroupIntercomScreen> {
  String? _groupCode;
  final List<R2Account> _members = [];
  bool _isPressed = false;
  R2IntercomEngine? _r2intercom;
  final _manager = R2UserManager();

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
    // Ensure the context is available by deferring the request
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestMyGroup();
    });
  }

  _initR2Intercom(int groupId) {
    final account = _members.first;
    _r2intercom =
        R2IntercomEngine.getInstance(groupID: groupId, userID: account.uid);
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
          ..avatarPath = memberData['userAvatar'] ?? '';

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
    // loading indicator for requesting group and its members
    R2LoadingIndicator.show(context);

    final token = await _manager.readToken();
    final api = CommonApi.defaultClient();
    final response = await api.getMyGroup(apiToken: token);

    // stop the indicator
    if (mounted) {
      R2LoadingIndicator.stop(context);
    }

    if ((response['success'] ?? false) == true) {
      debugPrint('Request succeeded: ${response['message']}');
      debugPrint('Response code: ${response['code']}');
      debugPrint('Result: ${response['result']}');

      final Map<String, dynamic> resultData =
          (response['result'] ?? {}) as Map<String, dynamic>;

      if (resultData.values.every((value) => value == null)) {
        // empty group object indicates that user has left the group
        if (mounted) {
          R2Flash.showBasicFlash(
            context: context,
            message:
                '${AppLocalizations.of(context)!.exitGroupMessage} (${response['code']})',
            duration: const Duration(seconds: 3),
          );
        }
        // remove local cached invalid group
        final group = await _manager.localGroup();
        final ret = await _manager.leaveGroup(group!.groupId);
        debugPrint('$runtimeType : leave group ${group.groupId} : $ret');

        // do not pop till flash finishes
        Future.delayed(const Duration(seconds: 3), () async {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        int groupNum = resultData['groupNum'];

        // save group
        final account = await _manager.localAccount();
        final groupId = resultData['id'];
        final code = resultData['groupName'];
        final group = R2Group(groupId: groupId, groupCode: code);
        final ret = await _manager.saveGroup(account!.uid, group);
        debugPrint('$runtimeType : save group $groupId : $ret');

        String formattedString =
            groupNum.toString().padLeft(4, '0'); // Convert to 4-digit string
        debugPrint('Formatted Result: $formattedString');
        setState(() {
          _groupCode = formattedString;
        });
        _decodeMemberList(resultData);
        _initR2Intercom(groupId);
      }
    } else {
      debugPrint('Failed to request my group: ${response['code']}');
      if (mounted) {
        R2Flash.showBasicFlash(
          context: context,
          message: '${response['message']} (${response['code']})',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _leaveMyGroup() async {
    // loading indicator for leaving group
    R2LoadingIndicator.show(context);

    final token = await _manager.readToken();
    final api = CommonApi.defaultClient();
    final response = await api.leaveGroup(apiToken: token);

    // stop the indicator
    if (mounted) {
      R2LoadingIndicator.stop(context);
    }

    if ((response['success'] ?? false) == true) {
      debugPrint('Request succeeded: ${response['message']}');
      debugPrint('Response code: ${response['code']}');
      debugPrint('Result: ${response['result']}');

      // delete local group data
      final group = await _manager.localGroup();
      final ret = await _manager.leaveGroup(group!.groupId);
      debugPrint('$runtimeType : remove local cached group data : $ret');
    } else {
      debugPrint('Failed to leave group code: ${response['code']}');
      if (mounted) {
        R2Flash.showBasicFlash(
          context: context,
          message: '${response['message']} (${response['code']})',
          duration: const Duration(seconds: 3),
        );
      }
    }

    // pop till leaving task completes
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /*
   * callback of rtc engine,
   * handle tasks right after local user is a member of rtc group.
   * uid: local user id allocated by Agora
   */
  void _onLocalJoined(int uid) {
    // todo: implementation
  }

  /*
   * handle tasks right after a member entering rtc group.
   * uid: user id allocated by Agora
   */
  void _onMemberJoined(int uid) {
    // todo: implementation
  }

  /*
   * callback of rtc engine,
   * handle tasks right after a member leaving rtc group.
   * uid: user id allocated by Agora
   */
  void _onMemberLeft(int uid) {
    // todo: implementation
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
    // Add logic to start or stop intercom here
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
   * show the members of the intercom group.
   * there are no more than 8 members and organized in two rows,
   * 4 members per row.
   * an avatar and a nickname of user represents him/her.
   */
  Widget _groupMemberWidget(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width *
            0.9, // Constrain to 90% of screen width
        child: GridView.builder(
          shrinkWrap:
              true, // When used in Column, ensure GridView doesn't expand to occupy entire space
          physics:
              const NeverScrollableScrollPhysics(), // Disable GridView scrolling to avoid conflicts with external scrolling
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 members per row
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.0,
            childAspectRatio:
                0.7, // Make items taller to provide more space for avatar and text
          ),
          itemCount: _members.length,
          itemBuilder: (context, index) {
            final member = _members[index];
            return Column(
              children: [
                FutureBuilder<Image>(
                  future: member.getAvatar(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 35.0,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const CircleAvatar(
                        radius: 35.0,
                        child: Icon(Icons.error),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 35.0,
                        backgroundImage: snapshot.data?.image,
                      );
                    }
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  member.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /*
   * Show leave group confirmation dialog
   */
  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          content: Container(
            constraints: const BoxConstraints(
              maxHeight: 80.0,
              minHeight: 60.0,
              maxWidth: 320.0,
              minWidth: 280.0,
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.confirmExitGroup,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: AppConstants.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: AppConstants.textColor,
                ),
              ),
            ),
            const SizedBox(width: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _leaveMyGroup();
                if (_r2intercom != null) {
                  _r2intercom!.stopIntercom();
                }
              },
              child: Text(
                AppLocalizations.of(context)!.exit,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: AppConstants.textColor,
                ),
              ),
            ),
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
        width: 250.0,
        height: 250.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? [
                  const BoxShadow(
                      color: AppConstants.primaryColor300,
                      blurRadius: 15,
                      offset: Offset(0, 0),
                      spreadRadius: 5)
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background image
            Container(
              width: 250.0,
              height: 250.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/intercom_button.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Text overlay
            Text(
              _isPressed
                  ? AppLocalizations.of(context)!.talking
                  : AppLocalizations.of(context)!.holdToTalk,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_groupCode ?? AppLocalizations.of(context)!.cyclingIntercom),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (Route<dynamic> route) => false,
            );
            _r2intercom!.stopIntercom();
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/icon_leave_group.png',
              width: 30.0,
              height: 30.0,
            ),
            onPressed: () {
              _showLeaveGroupDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 30.0),
          _groupMemberWidget(context),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: _intercomButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
