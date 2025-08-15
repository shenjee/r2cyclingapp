import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';

// application id provide by Shengwang
const swAppId = "";
const swToken = "";

typedef IntercomCallback = void Function(int value);

class R2IntercomEngine {
  // Private constructor for singleton
  R2IntercomEngine._internal({
    required int groupID,
    required int userID,
    this.onLocalJoined,
    this.onMemberJoined,
    this.onMemberLeft,
    this.onMemberSpeaking,
  })  : _groupID = groupID,
        _userID = userID;

  static R2IntercomEngine? _instance;

  // Singleton factory method
  static R2IntercomEngine? getInstance({
    int? groupID,
    int? userID,
    IntercomCallback? onLocalJoined,
    IntercomCallback? onMemberJoined,
    IntercomCallback? onMemberLeft,
    IntercomCallback? onMemberSpeaking,
  }) {
    if (_instance == null) {
      if (groupID == null || userID == null) {
        return null;
      }
      _instance = R2IntercomEngine._internal(
        groupID: groupID,
        userID: userID,
        onLocalJoined: onLocalJoined,
        onMemberJoined: onMemberJoined,
        onMemberLeft: onMemberLeft,
        onMemberSpeaking: onMemberSpeaking,
      );
    }
    return _instance!;
  }

  final int? _groupID;
  final int? _userID;
  final IntercomCallback? onLocalJoined;
  final IntercomCallback? onMemberJoined;
  final IntercomCallback? onMemberLeft;
  final IntercomCallback? onMemberSpeaking;

  late RtcEngine _engine;
  String? _rtcAppId;
  String? _rtcToken;

  Future<void> _requestRTCToken() async {
    final r2token = await R2Storage.getToken();
    final r2request = R2HttpRequest();
    final r2response = await r2request.postRequest(
      api: 'groupRoom/getVoiceToken',
      token: r2token,
      body: {
        'cyclingGroupId':'$_groupID',
      }
    );

    if (true == r2response.success && 200 == r2response.code) {
      _rtcAppId = r2response.result['appId'];
      _rtcToken = r2response.result['token'];
      
      debugPrint('_rtcAppId: $_rtcAppId');
      debugPrint('_rtcToken: $_rtcToken');
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

    try {
      await _engine.joinChannelWithUserAccount(
        token: _rtcToken!,
        channelId: _groupID.toString(),
        userAccount: _userID.toString(),
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