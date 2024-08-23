import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';

import 'dart:convert';

// application id provide by Shengwang
// const appId = "e861b361b8754affbe1cd3772b20d040";

typedef IntercomCallback = void Function(int value);

class R2IntercomEngine {
  final int? _groupID;
  final int? _userID;
  final IntercomCallback? onLocalJoined;
  final IntercomCallback? onMemberJoined;
  final IntercomCallback? onMemberLeft;
  final IntercomCallback? onMemberSpeaking;

  R2IntercomEngine({
    required int groupID,
    required int userID,
    this.onLocalJoined,
    this.onMemberJoined,
    this.onMemberLeft,
    this.onMemberSpeaking,
  }) : _groupID = groupID,
        _userID = userID;

  late RtcEngine _engine;
  String? _rtcAppId;
  String? _rtcToken;

  Future<void> _requestRTCToken() async {
    final r2token = await R2Storage.getToken();
    final r2request = R2HttpRequest();
    final r2response = await r2request.sendRequest(
      api: 'cyclingGroup/enterGroupVoice',
      token: r2token,
      body: {
        'cyclingGroupId':'$_groupID',
      }
    );

    if (true == r2response.success && 200 == r2response.code) {
      _rtcAppId = r2response.result['appId'];
      _rtcToken = r2response.result['token'];
    }
  }

  /*
   * initialize the Agora rtc engine developed by Shengwang
   */
  Future<void> initAgora() async {
    // get the microphone permission
    await [Permission.microphone].request();

    // request appid and token for RTC
    await _requestRTCToken();

    // create and instance of rtc engine
    _engine = createAgoraRtcEngine();
    // initialize RtcEngine for live broadcasting
    await _engine.initialize(RtcEngineContext(
      appId: _rtcAppId!,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // register an event handler to handle the group action
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        // the local user has joined group
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          onLocalJoined?.call(connection.localUid!);
        },
        // the remote member has joined group
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("$runtimeType: remote user $remoteUid joined");
          onMemberJoined?.call(remoteUid);
        },
        // the remote member has left group
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("$runtimeType: remote user $remoteUid left channel");
          onMemberLeft?.call(remoteUid);
        },
        onActiveSpeaker: (RtcConnection connection, int uid) {
          debugPrint("$runtimeType: current speaker $uid");
          onMemberSpeaking?.call(uid);
        }
      ),
    );

    final base64String = await R2Storage.getToken();
    // 拆分 JWT 为三部分
    final parts = base64String!.split('.');

    if (parts.length != 3) {
      debugPrint('Invalid token');
      return;
    }

    // 解码有效载荷部分
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decodedPayload = utf8.decode(base64Url.decode(normalized));

    print('Decoded Payload: $decodedPayload');

    // 解析 JSON 并获取 userId
    final payloadMap = jsonDecode(decodedPayload);

    final userId = payloadMap['data']['userId'];
    print('UserId: $userId');

    // join a channel

    try {
      await _engine.joinChannelWithUserAccount(
        token: _rtcToken!,
        channelId: _groupID!.toString(),
        userAccount: userId.toString(),
        options: const ChannelMediaOptions(
            autoSubscribeAudio: true,
            publishMicrophoneTrack: true,
            clientRoleType: ClientRoleType.clientRoleBroadcaster),
      );
    } catch (e) {
      debugPrint('$runtimeType : $e');
    }

    // mute mic input initially
    _engine.muteLocalAudioStream(true);
  }

  /*
   *
   */
  Future<void> pauseSpeak(bool mute) async {
    _engine.muteLocalAudioStream(mute);
  }

  /*
   * stop intercom
   */
  Future<void> stopIntercom() async {
    debugPrint('$runtimeType: stop intercom');
    await _engine.leaveChannel();
    await _engine.release();
  }
}