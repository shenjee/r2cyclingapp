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

import 'package:r2cyclingapp/connection/http/openapi/api_client.dart';
import 'dart:io';

class CommonApi {
  final ApiClient _client;
  CommonApi(this._client);

  factory CommonApi.defaultClient() => CommonApi(ApiClient());

  Future<Map<String, dynamic>> appInit(
      {required String clientTypeCode, String? apiToken}) {
    return _client.getJson(
      'common/appInit',
      query: {'clientTypeCode': clientTypeCode},
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> passwordLogin({
    required String loginId,
    required String sid,
    required String userPsw,
    String? validateCode,
    String? apiToken,
  }) {
    final form = <String, String>{
      'loginId': loginId,
      'sid': sid,
      'userPsw': userPsw,
      'validateCode': validateCode ?? '',
    };
    return _client.postFormString(
      'common/passwordLogin',
      form: form,
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> sendAuthCode({
    required String sid,
    required String userMobile,
    String? apiToken,
  }) {
    final form = <String, String>{
      'sid': sid,
      'userMobile': userMobile,
    };
    return _client.postFormString(
      'common/sendAuthCode',
      form: form,
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> mobileLogin({
    required String sid,
    required String userMobile,
    required String validateCode,
    String? apiToken,
  }) {
    final form = <String, String>{
      'sid': sid,
      'userMobile': userMobile,
      'validateCode': validateCode,
    };
    return _client.postFormString(
      'common/mobileLogin',
      form: form,
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> modUserPass({
    required String sid,
    required String modPassword,
    String? apiToken,
  }) {
    final form = <String, String>{
      'sid': sid,
      'modPassword': modPassword,
    };
    return _client.postFormString(
      'user/modUserPass',
      form: form,
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> getMember({
    String? apiToken,
  }) {
    return _client.getJsonFull(
      'member/getMember',
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> getMyGroup({
    String? apiToken,
  }) {
    return _client.getJsonFull(
      'cyclingGroup/getMyGroup',
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> leaveGroup({
    String? apiToken,
  }) {
    return _client.postFormString(
      'cyclingGroup/leaveGroup',
      form: const <String, String>{},
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> joinGroup({
    required String joinCode,
    String? apiToken,
  }) {
    return _client.postFormString(
      'cyclingGroup/joinGroup',
      form: <String, String>{'joinCode': joinCode},
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> newGroup({
    String? apiToken,
  }) {
    return _client.postFormString(
      'cyclingGroup/newGroup',
      form: const <String, String>{},
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> fallDownReport({
    required String eventLat,
    required String eventLon,
    String? apiToken,
  }) {
    return _client.postFormString(
      'locationEvent/fallDownReport',
      form: <String, String>{
        'eventLat': eventLat,
        'eventLon': eventLon,
      },
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> switchContactEnabled({
    required String emergencyContactEnabled,
    String? apiToken,
  }) {
    return _client.postFormString(
      'member/switchContactEnabled',
      form: <String, String>{
        'emergencyContactEnabled': emergencyContactEnabled,
      },
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> saveEmergencyContact({
    required String emergencyContactId,
    required String contactMan,
    required String contactManMobile,
    String? apiToken,
  }) {
    return _client.postFormString(
      'emergencyContact/saveEmergencyContact',
      form: <String, String>{
        'emergencyContactId': emergencyContactId,
        'contactMan': contactMan,
        'contactManMobile': contactManMobile,
      },
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> deleteEmergencyContact({
    required String emergencyContactId,
    String? apiToken,
  }) {
    return _client.postFormString(
      'emergencyContact/deleteEmergencyContact',
      form: <String, String>{
        'emergencyContactId': emergencyContactId,
      },
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> listEmergencyContact({
    String? apiToken,
  }) {
    return _client.getJsonFull(
      'emergencyContact/listEmergencyContact',
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> getVoiceToken({
    required String cyclingGroupId,
    String? apiToken,
  }) {
    return _client.postFormString(
      'groupRoom/getVoiceToken',
      form: <String, String>{'cyclingGroupId': cyclingGroupId},
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> bindDevice({
    required String hwDeviceId,
    String hwDeviceVer = '',
    String? apiToken,
  }) {
    return _client.postFormString(
      'member/bindDevice',
      form: <String, String>{
        'hwDeviceId': hwDeviceId,
        'hwDeviceVer': hwDeviceVer,
      },
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> unBindDevice({
    String? apiToken,
  }) {
    return _client.postFormString(
      'member/unBindDevice',
      form: const <String, String>{},
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> modUserInfo({
    Map<String, String>? body,
    String? apiToken,
  }) {
    return _client.postFormString(
      'user/modUserInfo',
      form: body,
      apiToken: apiToken,
    );
  }

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    String? apiToken,
  }) {
    return _client.postMultipart(
      'tools/upload',
      file: file,
      fields: {
        'thumbHeight': '200',
        'thumbWidth': '200',
      },
      apiToken: apiToken,
    );
  }
}
