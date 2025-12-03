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
import 'dart:io';
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

  Future<Map<String, dynamic>> getJsonFull(
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
      return {
        'success': false,
        'message': 'Request failed: ${resp.statusCode}',
        'code': resp.statusCode,
        'result': null,
      };
    }
    try {
      final dynamic decoded = json.decode(resp.body);
      if (decoded is Map<String, dynamic>) {
        final bool success = (decoded['success'] ?? false) == true;
        final dynamic message = decoded['message'];
        final dynamic code = decoded['code'];
        final dynamic result = decoded['result'];
        return {
          'success': success,
          'message': message?.toString(),
          'code': code is int ? code : int.tryParse('${code ?? 0}') ?? 0,
          'result': result,
        };
      }
    } catch (_) {}
    return {
      'success': false,
      'message': 'Invalid response',
      'code': 500,
      'result': null,
    };
  }

  Future<Map<String, dynamic>> postFormString(
    String path, {
    Map<String, String>? form,
    String? apiToken,
  }) async {
    final uri = Uri.parse('$_baseHost$_basePath$path');
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    if (apiToken != null && apiToken.isNotEmpty) {
      headers['apiToken'] = apiToken;
    }
    final resp = await http.post(uri,
        headers: headers, body: form ?? const <String, String>{});
    if (resp.statusCode != 200) {
      return {
        'success': false,
        'message': 'Request failed: ${resp.statusCode}',
        'code': resp.statusCode,
        'result': null,
      };
    }
    try {
      final dynamic decoded = json.decode(resp.body);
      if (decoded is Map<String, dynamic>) {
        final bool success = (decoded['success'] ?? false) == true;
        final dynamic message = decoded['message'];
        final dynamic code = decoded['code'];
        final dynamic result = decoded['result'];
        return {
          'success': success,
          'message': message?.toString(),
          'code': code is int ? code : int.tryParse('${code ?? 0}') ?? 0,
          'result': result,
        };
      }
    } catch (_) {}
    return {
      'success': false,
      'message': 'Invalid response',
      'code': 500,
      'result': null,
    };
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required File file,
    String fileField = 'file',
    Map<String, String>? fields,
    String? apiToken,
  }) async {
    final uri = Uri.parse('$_baseHost$_basePath$path');
    final request = http.MultipartRequest('POST', uri);

    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Add headers
    request.headers['Accept'] = 'application/json';
    if (apiToken != null && apiToken.isNotEmpty) {
      request.headers['apiToken'] = apiToken;
    }

    // Add file
    final multipartFile = await http.MultipartFile.fromPath(
      fileField,
      file.path,
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send();
      final resp = await http.Response.fromStream(streamedResponse);

      if (resp.statusCode != 200) {
        return {
          'success': false,
          'message': 'Request failed: ${resp.statusCode}',
          'code': resp.statusCode,
          'result': null,
        };
      }

      final dynamic decoded = json.decode(resp.body);
      if (decoded is Map<String, dynamic>) {
        final bool success = (decoded['success'] ?? false) == true;
        final dynamic message = decoded['message'];
        final dynamic code = decoded['code'];
        final dynamic result = decoded['result'];
        return {
          'success': success,
          'message': message?.toString(),
          'code': code is int ? code : int.tryParse('${code ?? 0}') ?? 0,
          'result': result,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Request error: $e',
        'code': 500,
        'result': null,
      };
    }

    return {
      'success': false,
      'message': 'Invalid response',
      'code': 500,
      'result': null,
    };
  }
}
