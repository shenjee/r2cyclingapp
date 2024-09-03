import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';

import 'package:r2cyclingapp/usermanager/r2_account.dart';
import 'package:r2cyclingapp/usermanager/r2_group.dart';
import 'package:r2cyclingapp/usermanager/r2_user_profile.dart';

class R2UserManager {
  final _db = R2DBHelper();

  // private method
  int _tokenExp(String token) {
    // 拆分 JWT 为三部分
    final parts = token.split('.');

    if (parts.length != 3) {
      debugPrint('Invalid token');
      return 0;
    }

    // the second part of the token
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decodedPayload = utf8.decode(base64Url.decode(normalized));

    debugPrint('$runtimeType : Decoded Payload: $decodedPayload');

    // analyze JSON and fetch data
    final payloadMap = jsonDecode(decodedPayload);
    final intDate = payloadMap['exp'];

    return intDate;
  }

  Map<String,dynamic> _decodeToken(String token) {
    // 拆分 JWT 为三部分
    final parts = token.split('.');

    if (parts.length != 3) {
      debugPrint('Invalid token');
      return {'na':'na'};
    }

    // the second part of the token
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decodedPayload = utf8.decode(base64Url.decode(normalized));

    debugPrint('$runtimeType : Decoded Payload: $decodedPayload');

    // analyze JSON and fetch data
    final payloadMap = jsonDecode(decodedPayload);
    final dataMap = payloadMap['data'];

    return dataMap;
  }

  Future<void> saveToken(String token) async {
    await R2Storage.save('authtoken',token);
  }

  Future<String?> readToken()async {
    return await R2Storage.read('authtoken');
  }

  /*
   * expired token returns ture, else false.
   * a token is valid within 30 days.
   */
  bool expiredToken({String? token}) {
    bool isExpired = false;

    if (token != null) {
      final expiredDate = _tokenExp(token);

      if (expiredDate > 0) {
        // Convert Unix timestamp to DateTime (in milliseconds)
        DateTime timestampDate = DateTime.fromMillisecondsSinceEpoch(
            expiredDate * 1000);

        // Get the current local date and time
        DateTime currentTime = DateTime.now();

        // Compare the two dates
        if (currentTime.isAfter(timestampDate)) {
          isExpired = true;
        } else {
          isExpired = false;
        }
      }
    }
    return isExpired;
  }

  Future<void> deleteToken() async {
    await R2Storage.delete('authtoken');
  }

  Future<int> saveAccountWithToken(String token) async {
    // Decode the token to get user details
    final dataMap = _decodeToken(token);
    final userId = dataMap['userId'] ?? 0;
    final userAccount = dataMap['loginId'] ?? '';

    // Create R2Account and save it to the database
    debugPrint('$runtimeType : User saved with token.');
    final r2a = R2Account(uid: userId, account: userAccount);
    return await _db.saveAccount(r2a);
  }

  Future<int> saveUser(int uid, String account) async {
    final r2a = R2Account(uid:uid, account: account);
    return await _db.saveAccount(r2a);
  }

  Future<int> deleteUser(int uid) async {
    return await _db.deleteAccount(uid);
  }

  Future<R2Account?> localAccount() async {
    final account = await _db.getAccount();
    return account;
  }

  Future<int?> saveGroup(int uid, R2Group group) async {
    return await _db.saveGroup(uid, group);
  }

  Future<R2Group?> localGroup() async {
    final account = await _db.getAccount();
    final group = await _db.getGroup(account!.uid);
    return group;
  }

  Future<int?> leaveGroup(int gid) async {
    return await _db.deleteGroup(gid);
  }

  Future<R2UserProfile?> requestUserProfile() async {
    R2UserProfile? profile;
    final token = await readToken();
    final request = R2HttpRequest();
    final response = await request.getRequest(
      api: 'member/getMember',
      token: token,
    );

    if (true == response.success) {
      debugPrint('$runtimeType : message ${response.message}');
      final Map<String, dynamic> data = response.result;
      final groupId = data['cyclingGroupId'];
      final group = R2Group(gid: groupId ?? 0);
      final account = await _db.getAccount();
      // save group info
      _db.saveGroup(account!.uid, group);
    } else {
      debugPrint('$runtimeType : request profile info failed: ${response.code}');
    }

    return profile;
  }

  /*
   * update the nickname and save it
   *
   * userId: the id of account.
   *         if it is not provided, default account is the local user.
   * value:  new nickname
   */
  Future<int> updateNickname({int? userId, String? value}) async {
    if (null == userId) {
      // update local account's nickname
      final r2a = await localAccount();
      r2a!.nickname = value!;
      return await _db.saveAccount(r2a);
    } else {
      // update specified user's nickname
      return 0;
    }
  }

  /*
   * update the nickname and save it
   *
   * userId: the id of account.
   *         if it is not provided, default account is the local user.
   * value: the path of avatar image
   */
  Future<int> updateAvatar({int? userId, String? value}) async {
    if (null == userId) {
      // update local account's nickname
      final r2a = await localAccount();
      r2a!.avatarPath = value!;
      return await _db.saveAccount(r2a);
    } else {
      // update specified user's nickname
      return 0;
    }
  }
}