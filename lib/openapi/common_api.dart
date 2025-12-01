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

import 'package:r2cyclingapp/openapi/api_client.dart';

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

  Future<String> passwordLogin({
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

  Future<String> sendAuthCode({
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

  Future<String> mobileLogin({
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
}
