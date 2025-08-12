import 'package:http/http.dart' as http;
import 'r2_http_response.dart';

class R2HttpRequest {
  // Base URL is fixed.
  final String _baseUrl = 'https://rock.r2cycling.com/api/';

  // Method to send the POST request.
  Future<R2HttpResponse> postRequest({String? token, required String api, Map<String, String>? body}) async {
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
}