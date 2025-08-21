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

import 'dart:convert';

class R2HttpResponse {
  final bool _success;
  final String _message;
  final int _code;
  final String? _stackTracke;
  final dynamic _result;

  R2HttpResponse({
    required bool success,
    required String message,
    required int code,
    String? stackTracke,
    required dynamic result
  }) : _success = success,
        _message = message,
        _code = code,
        _stackTracke = stackTracke,
        _result = result;

  // Getters
  bool get success => _success;
  String get message => _message;
  int get code => _code;
  String? get stackTracke => _stackTracke;
  dynamic get result => _result;

  static dynamic _parseResult(dynamic result) {
    if (result is String) {
      try {
        final decoded = json.decode(result);
        if (decoded is Map<String, dynamic> || decoded is List<dynamic>) {
          return decoded;
        }
      } catch (e) {
        // If parsing fails, retain the original string.
      }
    }
    return result;
  }

  factory R2HttpResponse.fromJson(String responseBody) {
    final Map<String, dynamic> json_map = json.decode(responseBody);

    return R2HttpResponse(
      success: json_map['success']??false,
      message: json_map['message']??'',
      code: json_map['code']??0,
      stackTracke: json_map['stackTracke'],
      result: _parseResult(json_map['result']),
    );
  }
}