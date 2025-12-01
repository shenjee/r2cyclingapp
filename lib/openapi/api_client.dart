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
import 'package:http/http.dart' as http;

class ApiClient {
  final String _baseHost = 'https://rock.r2cycling.com';
  final String _basePath = '/api/';

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    String? apiToken,
  }) async {
    final uri =
        Uri.parse('$_baseHost$_basePath$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    if (apiToken != null && apiToken.isNotEmpty) {
      headers['apiToken'] = apiToken;
    }
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Request failed: ${resp.statusCode}');
    }
    final dynamic body = json.decode(resp.body);
    if (body is Map<String, dynamic>) {
      final dynamic result = body['result'];
      if (result is Map<String, dynamic>) {
        return result;
      } else if (result is String) {
        try {
          final decoded = json.decode(result);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } catch (_) {}
      }
      return body;
    }
    return <String, dynamic>{};
  }
}
