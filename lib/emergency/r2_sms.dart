import 'package:flutter/services.dart';

class R2Sms {
  static const MethodChannel _platform = MethodChannel('r2_sms_channel');

  static Future<void> sendSMS(String phoneNumber, String message) async {
    try {
      final Map<String, dynamic> params = <String, dynamic>{
        'phoneNumber': phoneNumber,
        'message': message,
      };
      await _platform.invokeMethod('sendSMS', params);
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'.");
    }
  }
}
