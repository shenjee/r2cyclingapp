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

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'r2_http_response.dart';

class R2HttpRequest {
  // Base URL is fixed.
  final String _baseUrl = 'https://rock.r2cycling.com/api/';

  // Method to send the POST request.
  Future<R2HttpResponse> postRequest({String? token, required String api, Map<String, dynamic>? body}) async {
    final String url = '$_baseUrl$api'; // Construct the full URL.

    // Initialize headers with content type.
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    // Add the token to headers if it is provided.
    if (token != null && token.isNotEmpty) {
      headers['apiToken'] = token;
    }

    try {
      http.Response response;
      // Send the POST request.
      if (null == body) {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
        );
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        );
      }

      // Convert the HTTP response to R2HttpResponse.
      if (response.statusCode == 200) {
        return R2HttpResponse.fromJson(response.body);
      } else {
        return R2HttpResponse(
          success: false,
          message: 'Request failed with status: ${response.statusCode}',
          code: response.statusCode,
          result: null,
        );
      }
    } catch (e) {
      // Handle errors.
      return R2HttpResponse(
        success: false,
        message: e.toString(),
        code: 500,
        result: null,
      );
    }
  }

  // Method to send the POST request.
  Future<R2HttpResponse> getRequest({String? token, required String api}) async {
    final String url = '$_baseUrl$api'; // Construct the full URL.

    // Initialize headers with content type.
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    // Add the token to headers if it is provided.
    if (token != null && token.isNotEmpty) {
      headers['apiToken'] = token;
    }

    try {
      http.Response response;
      // Send the POST request.
      response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      // Convert the HTTP response to R2HttpResponse.
      if (response.statusCode == 200) {
        return R2HttpResponse.fromJson(response.body);
      } else {
        return R2HttpResponse(
          success: false,
          message: 'Request failed with status: ${response.statusCode}',
          code: response.statusCode,
          result: null,
        );
      }
    } catch (e) {
      // Handle errors.
      return R2HttpResponse(
        success: false,
        message: e.toString(),
        code: 500,
        result: null,
      );
    }
  }

  // Method to upload a file using multipart/form-data
  Future<R2HttpResponse> uploadFile({String? token, required String api, required File file}) async {
    final String url = '$_baseUrl$api'; // Construct the full URL.
    
    // Create a multipart request
    final request = http.MultipartRequest('POST', Uri.parse(url));
    
    // Add the file to the request
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();
    final multipartFile = http.MultipartFile(
      'file', // parameter name as specified in the API
      fileStream,
      fileLength,
      filename: basename(file.path),
    );
    request.files.add(multipartFile);

    // Add thumbnail parameters required by tools/upload
    if (api == 'tools/upload') {
      request.fields['thumbHeight'] = '200';
      request.fields['thumbWidth'] = '200';
    }
    
    // Add required headers
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Accept'] = 'application/json';
    
    // Add the token to headers if it is provided
    if (token != null && token.isNotEmpty) {
      request.headers['apiToken'] = token;
    }
    
    try {
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Convert the HTTP response to R2HttpResponse
      if (response.statusCode == 200) {
        return R2HttpResponse.fromJson(response.body);
      } else {
        return R2HttpResponse(
          success: false,
          message: 'Request failed with status: ${response.statusCode}',
          code: response.statusCode,
          result: null,
        );
      }
    } catch (e) {
      // Handle errors
      return R2HttpResponse(
        success: false,
        message: e.toString(),
        code: 500,
        result: null,
      );
    }
  }
}