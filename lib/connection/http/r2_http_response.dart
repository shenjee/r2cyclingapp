import 'dart:convert';

class R2HttpResponse {
  final bool success;
  final String message;
  final int code;
  final String? stackTracke;
  final dynamic result;

  R2HttpResponse({
    required this.success,
    required this.message,
    required this.code,
    this.stackTracke,
    required this.result
  });

  static dynamic _parseResult(dynamic result) {
    if (result is String) {
      try {
        final decoded = json.decode(result);
        if (decoded is Map<String, dynamic> || decoded is List<dynamic>) {
          return decoded;
        }
      } catch (e) {
        // 如果解析失败，保留原始字符串
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