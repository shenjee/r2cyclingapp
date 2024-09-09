import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BluetoothAudioManager {
  static const platform = MethodChannel('r2_sms_channel');

  static Future<void> enableAudioProfiles(String deviceAddress) async {
    try {
      await platform.invokeMethod('enableAudioProfiles', {"deviceAddress": deviceAddress});
    } on PlatformException catch (e) {
      debugPrint("Failed to enable audio profiles: ${e.message}");
    }
  }
}
