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
import 'dart:convert';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/connection/http/openapi/common_api.dart';

import 'package:r2cyclingapp/usermanager/r2_account.dart';
import 'package:r2cyclingapp/usermanager/r2_group.dart';
import 'package:r2cyclingapp/devicemanager/r2_device.dart';
import 'package:r2cyclingapp/usermanager/r2_user_profile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// import moved: use CommonApi for HTTP

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

  Map<String, dynamic> _decodeToken(String token) {
    // 拆分 JWT 为三部分
    final parts = token.split('.');

    if (parts.length != 3) {
      debugPrint('Invalid token');
      return {'na': 'na'};
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
    await R2Storage.save('authtoken', token);
  }

  Future<String?> readToken() async {
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
        DateTime timestampDate =
            DateTime.fromMillisecondsSinceEpoch(expiredDate * 1000);

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
    final r2a = R2Account(uid: uid, account: account);
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
    if (account == null) {
      return null;
    }
    final group = await _db.getGroup(account.uid);
    return group;
  }

  Future<int?> leaveGroup(int groupId) async {
    return await _db.deleteGroup(groupId);
  }

  Future<R2UserProfile?> requestUserProfile() async {
    R2UserProfile? profile;
    final token = await readToken();
    final commonApi = CommonApi.defaultClient();
    final resp = await commonApi.getMember(apiToken: token);

    if ((resp['success'] ?? false) == true) {
      debugPrint('$runtimeType : message ${resp['message']}');
      final Map<String, dynamic> data =
          (resp['result'] ?? {}) as Map<String, dynamic>;

      // Create and save R2Account from API response
      final account = R2Account(
        uid: data['userId'] ?? 0,
        account: data['loginId'] ?? '',
      )
        ..phoneNumber = data['userMobile'] ?? ''
        ..nickname = data['userName'] ?? ''
        ..avatarPath = data['userAvatar'] ?? ''
        ..isPasswdSet = data['defaultPassword'] != true;

      await _db.saveAccount(account);

      // Create and save R2Group from API response
      if (data['cyclingGroupId'] != null && data['cyclingGroupId'] != 0) {
        final group = R2Group(
          groupId: data['cyclingGroupId'],
          groupCode:
              data['groupNum']?.toString() ?? 'Group ${data['cyclingGroupId']}',
        );
        await _db.saveGroup(account.uid, group);
      }

      // Create and save R2Device from API response
      if (data['hwDeviceId'] != null &&
          data['hwDeviceId'].toString().isNotEmpty) {
        final address = _formatMacAddress(data['hwDeviceId']?.toString() ?? '');
        final device = R2Device(
          deviceId: data['hwDeviceId']?.toString() ?? '',
          model: data['hwDeviceModelId']?.toString() ?? '',
          brand: data['manufacturerId']?.toString() ?? '',
          name:
              '${data['manufacturerId']?.toString()} ${data['hwDeviceId']?.toString() ?? ''}',
          // so now deviceId is ble address, format is '9AD3B79F27A6'
          // it should be converted to '9A:D3:B7:9F:27:A6'
          // todo: Refactor device class on server side to improve data structure and consistency
          bleAddress: address,
        );
        await _db.saveDevice(device);
      }

      // Save emergency contact setting
      if (data['ifEmergencyContactEnable'] != null) {
        final isEnabled = data['ifEmergencyContactEnable'].toString() == 'Y';
        await _db.saveEmergencyContactEnabled(isEnabled);
      }
    } else {
      debugPrint('$runtimeType : request profile info failed: ${resp['code']}');
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
      final saved = await _db.saveAccount(r2a);
      // sync to server
      await _updateUserProfile(nickName: value);
      return saved;
    } else {
      // update specified user's nickname
      return 0;
    }
  }

  Future<Image> getAvatar() async {
    try {
      final r2a = await localAccount();
      if (r2a == null) {
        return Image.asset('assets/icons/default_avatar.png');
      }
      final int uid = r2a.uid;

      // 1) Check local cache via helper
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Image? cached = await _readAvatarImage(uid);
      if (cached != null) {
        return cached;
      }

      // 3) If avatarPath is empty, return default immediately
      final String avatarPath = (r2a.avatarPath).trim();
      if (avatarPath.isEmpty) {
        return Image.asset('assets/icons/default_avatar.png');
      }

      // 2) No cache, try download from https: _baseUrl (host) + fileDomain + avatarPath
      String fileDomain = (await R2Storage.read('fileDomain') ?? '').trim();
      if (fileDomain.isEmpty) {
        return Image.asset('assets/icons/default_avatar.png');
      }
      // Normalize segments
      if (!fileDomain.startsWith('/')) fileDomain = '/$fileDomain';
      // Some fileDomain values may already include trailing slash; avoid double slashes
      if (!fileDomain.endsWith('/')) fileDomain = '$fileDomain/';

      String fileName = avatarPath;
      if (fileName.startsWith('/')) fileName = fileName.substring(1);

      // Base host for static files (images)
      const String baseHost = 'https://rock.r2cycling.com';
      final String url = '$baseHost$fileDomain$fileName';

      try {
        final api = CommonApi.defaultClient();
        final bytesResp = await api.getImageBytes(url: url);
        if (bytesResp.success && bytesResp.result != null) {
          final String extension = p.extension(fileName);
          // Write to a temporary file, then cache via helper
          final String tempPath =
              p.join(appDir.path, 'avatar_${uid}_temp$extension');
          final File tempFile = File(tempPath);
          try {
            await tempFile.writeAsBytes(bytesResp.result!);
            debugPrint('$runtimeType: start write $tempPath to cache');
            final String? cachedPath = await _writeAvatarImage(uid, tempPath);
            // Clean up temp file
            try {
              await tempFile.delete();
            } catch (_) {}

            if (cachedPath != null) {
              return Image.file(File(cachedPath));
            } else {
              debugPrint(
                  '$runtimeType : cache write failed for downloaded avatar');
              return Image.asset('assets/icons/default_avatar.png');
            }
          } catch (e) {
            debugPrint('getAvatar: write temp error $e');
            return Image.asset('assets/icons/default_avatar.png');
          }
        } else {
          debugPrint('getAvatar: download failed ${bytesResp.code} url=$url');
          return Image.asset('assets/icons/default_avatar.png');
        }
      } catch (e) {
        debugPrint('getAvatar: download error url=$url err=$e');
        return Image.asset('assets/icons/default_avatar.png');
      }
    } catch (e) {
      debugPrint('getAvatar: unexpected error $e');
      return Image.asset('assets/icons/default_avatar.png');
    }
  }

  /*
   * update the avatar image and save it
   *
   * userId: the id of account.
   *         if it is not provided, default account is the local user.
   * imagePath: the path and filename of avatar image
   * 
   * return 0 - success
   * return other - failed
   */
  Future<int> updateAvatar({int? userId, String? imagePath}) async {
    if (null == userId) {
      // use local account
      final r2a = await localAccount();
      if (r2a == null) {
        return -1;
      }
      final uid = r2a.uid;
      if (imagePath == null || imagePath.isEmpty) {
        return -1;
      }

      try {
        final srcFile = File(imagePath);
        if (await srcFile.exists()) {
          debugPrint('$runtimeType: start write $imagePath to cache');
          final String? cachedPath = await _writeAvatarImage(uid, imagePath);
          if (cachedPath == null) {
            debugPrint('updateAvatar: copy cache error');
            return -1;
          }

          // Upload cached file to server and sync profile
          String? serverFilename;
          try {
            final cachedFile = File(cachedPath);
            if (await cachedFile.exists()) {
              serverFilename = await _uploadAvatarImage(cachedFile);
            }
          } catch (e) {
            debugPrint('$runtimeType : updateAvatar sync error: $e');
          }

          // Save avatarPath as value returned by tools/upload
          if (serverFilename != null && serverFilename.isNotEmpty) {
            // Perform profile sync separately; only save locally when server confirms
            bool synced = false;
            try {
              synced = await _updateUserProfile(avatarFile: serverFilename);
            } catch (e) {
              debugPrint('$runtimeType : updateAvatar profile sync error: $e');
            }

            if (synced) {
              return 0;
            } else {
              debugPrint('$runtimeType : profile sync failed after upload');
              return -1;
            }
          } else {
            debugPrint('$runtimeType : upload avatar did not return filename');
            return -1;
          }
        } else {
          debugPrint(
              '$runtimeType : source avatar file does not exist: $imagePath');
          return -1;
        }
      } catch (e) {
        debugPrint('$runtimeType : updateAvatar cache error: $e');
        return -1;
      }
    } else {
      // TODO: support updating specified user's avatar if needed
      return -1;
    }
  }

  Future<String?> _writeAvatarImage(int uid, String srcPath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String ext = p.extension(srcPath);
      final String sanitizedExt = ext.isNotEmpty ? ext : '';

      // Delete old timestamped avatar files for this uid
      final RegExp oldPattern =
          RegExp('^avatar_${uid}_[0-9]+\\.[A-Za-z0-9]+\$');
      await for (var entity in appDir.list(followLinks: false)) {
        if (entity is File) {
          final String name = p.basename(entity.path);
          if (oldPattern.hasMatch(name)) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
      }

      // Write new cached file with timestamp
      final int ts = DateTime.now().millisecondsSinceEpoch;
      final String cachedPath =
          p.join(appDir.path, 'avatar_${uid}_${ts}${sanitizedExt}');
      final File srcFile = File(srcPath);
      if (!await srcFile.exists()) {
        return null;
      }
      debugPrint('$runtimeType : _writeAvatarImage $cachedPath');
      await srcFile.copy(cachedPath);
      return cachedPath;
    } catch (e) {
      debugPrint('$runtimeType : _writeAvatarImage error: ${e.toString()}');
      return null;
    }
  }

  Future<Image?> _readAvatarImage(int uid) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final RegExp pattern = RegExp('^avatar_${uid}_(\\d+)\\.[A-Za-z0-9]+\$');
      File? latestFile;
      int latestTs = -1;

      await for (var entity in appDir.list(followLinks: false)) {
        if (entity is File) {
          final String name = p.basename(entity.path);
          final Match? m = pattern.firstMatch(name);
          if (m != null) {
            final int ts = int.tryParse(m.group(1) ?? '') ?? -1;
            if (ts > latestTs) {
              latestTs = ts;
              latestFile = entity;
            }
          }
        }
      }

      if (latestFile != null) {
        debugPrint(
            '$runtimeType : _readAvatarImage found cached avatar $latestFile');
        return Image.file(latestFile);
      }
      return null;
    } catch (e) {
      debugPrint('$runtimeType : _readAvatarImage error: ${e.toString()}');
      return null;
    }
  }

  // Helper method to format device ID to MAC address format
  String _formatMacAddress(String deviceId) {
    if (deviceId.isEmpty || deviceId.length != 12) {
      return deviceId; // Return original if not valid format
    }

    // Insert colons every 2 characters
    return deviceId
        .replaceAllMapped(RegExp(r'(.{2})'), (match) => '${match.group(1)}:')
        .substring(0, 17); // Remove trailing colon
  }

  // Rename and adjust server sync helpers to be private
  Future<String?> _uploadAvatarImage(File imageFile) async {
    try {
      final token = await readToken();
      final api = CommonApi.defaultClient();
      final resp = await api.uploadFile(
        file: imageFile,
        apiToken: token,
      );

      if ((resp['success'] ?? false) == true) {
        final dynamic result = resp['result'];
        String? filename;
        if (result is Map) {
          final dynamic f = result['filename'];
          if (f != null) filename = f.toString();
        } else if (result is String) {
          filename = result.trim();
        }
        return (filename != null && filename.isNotEmpty) ? filename : null;
      } else {
        debugPrint(
            '$runtimeType : upload avatar failed: ${resp['message']} (${resp['code']})');
        return null;
      }
    } catch (e) {
      debugPrint('$runtimeType : upload avatar error: $e');
      return null;
    }
  }

  Future<bool> _updateUserProfile(
      {String? avatarFile, String? nickName}) async {
    // Build request body with only provided parameters
    final Map<String, String> body = {};

    if (avatarFile != null && avatarFile.isNotEmpty) {
      body['userAvatar'] = 'temp/$avatarFile';
    }
    if (nickName != null && nickName.isNotEmpty) {
      body['userName'] = nickName;
    }

    if (body.isEmpty) {
      return false;
    }

    try {
      final token = await readToken();
      final api = CommonApi.defaultClient();
      final resp = await api.modUserInfo(
        body: body,
        apiToken: token,
      );

      if ((resp['success'] ?? false) == true) {
        return true;
      } else {
        debugPrint(
            '$runtimeType : update profile failed: ${resp['message']} (${resp['code']})');
        return false;
      }
    } catch (e) {
      debugPrint('$runtimeType : update profile error: $e');
      return false;
    }
  }
}
