import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';

import 'package:r2cyclingapp/usermanager/r2_account.dart';

class R2UserManager {
  final _db = R2DBHelper();

  // private method
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
    final r2a = R2Account(id: userId, account: userAccount);
    return await _db.saveAccount(r2a);
  }

  Future<int> saveUser(int id, String account) async {
    final r2a = R2Account(id:id, account: account);
    return await _db.saveAccount(r2a);
  }

  Future<int> deleteUser(int id) async {
    return await _db.deleteAccount(id);
  }

  Future<R2Account?> localAccount() async {
    final account = await _db.getLocalAccount();
    return account;
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