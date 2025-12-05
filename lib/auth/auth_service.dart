import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:r2cyclingapp/connection/http/openapi/api_client.dart';
import 'package:r2cyclingapp/connection/http/openapi/common_api.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';

class AuthService {
  Future<String> _sid() async {
    final prefs = await SharedPreferences.getInstance();
    String? sid = prefs.getString('sessionId');
    if (sid == null || sid.isEmpty) {
      sid = const Uuid().v4();
      await prefs.setString('sessionId', sid);
    }
    return sid;
  }

  String _hash(String s) {
    final bytes = utf8.encode(s);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  Future<R2HttpResponse<String>> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    final sid = await _sid();
    final hashed = _hash('$phone$password');
    final api = CommonApi.defaultClient();
    final resp = await api.passwordLogin(
      loginId: phone,
      sid: sid,
      userPsw: hashed,
      validateCode: '',
    );
    final ok = (resp['success'] ?? false) == true;
    final token = (resp['result'] ?? '').toString();
    if (ok && token.isNotEmpty) {
      await R2Storage.save('authtoken', token);
      return R2HttpResponse<String>(success: true, code: 200, result: token);
    }
    final msg = resp['message']?.toString();
    final code = resp['code'] is int
        ? resp['code'] as int
        : int.tryParse('${resp['code'] ?? 0}') ?? 500;
    return R2HttpResponse<String>(
      success: false,
      code: code,
      message: msg ?? 'Login failed',
      errorKind: _classifyError(code, null),
    );
  }

  Future<R2HttpResponse<String>> loginWithCode({
    required String phone,
    required String code,
  }) async {
    final sid = await _sid();
    final api = CommonApi.defaultClient();
    final resp = await api.mobileLogin(
      sid: sid,
      userMobile: phone,
      validateCode: code,
    );
    final ok = (resp['success'] ?? false) == true;
    final token = (resp['result'] ?? '').toString();
    if (ok && token.isNotEmpty) {
      await R2Storage.save('authtoken', token);
      return R2HttpResponse<String>(success: true, code: 200, result: token);
    }
    final msg = resp['message']?.toString();
    final rc = resp['code'] is int
        ? resp['code'] as int
        : int.tryParse('${resp['code'] ?? 0}') ?? 500;
    return R2HttpResponse<String>(
      success: false,
      code: rc,
      message: msg ?? 'Login failed',
      errorKind: _classifyError(rc, null),
    );
  }

  Future<R2HttpResponse<void>> sendAuthCode({
    required String phone,
  }) async {
    final sid = await _sid();
    final api = CommonApi.defaultClient();
    final resp = await api.sendAuthCode(sid: sid, userMobile: phone);
    final ok = (resp['success'] ?? false) == true;
    if (ok) {
      return R2HttpResponse<void>(success: true, code: 200);
    }
    final msg = resp['message']?.toString();
    final rc = resp['code'] is int
        ? resp['code'] as int
        : int.tryParse('${resp['code'] ?? 0}') ?? 500;
    return R2HttpResponse<void>(
      success: false,
      code: rc,
      message: msg ?? 'Request failed',
      errorKind: _classifyError(rc, null),
    );
  }

  Future<void> saveToken(String token) async {
    await R2Storage.save('authtoken', token);
  }

  Future<String?> readToken() async {
    return await R2Storage.read('authtoken');
  }

  Future<void> deleteToken() async {
    await R2Storage.delete('authtoken');
  }

  bool expiredToken({String? token}) {
    if (token == null || token.isEmpty) return true;
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decodedPayload = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decodedPayload) as Map<String, dynamic>;
    final exp = map['exp'] is int ? map['exp'] as int : 0;
    if (exp <= 0) return true;
    final ts = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(ts);
  }

  R2HttpErrorKind _classifyError(int? code, Object? error) {
    if (code == 401) return R2HttpErrorKind.unauthorized;
    if (code == 403) return R2HttpErrorKind.forbidden;
    if (code == 404) return R2HttpErrorKind.notFound;
    if (code != null && code >= 500) return R2HttpErrorKind.server;
    return R2HttpErrorKind.unknown;
  }
}
