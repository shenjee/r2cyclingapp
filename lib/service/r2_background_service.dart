import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';
import 'package:r2cyclingapp/connection/bt/r2_ble_command.dart';
import 'package:r2cyclingapp/emergency/r2_sos_sender.dart';

class R2BackgroundService {
  final R2BluetoothModel _btModel = R2BluetoothModel();

  // temporary usage to simulate the detection of a fall
  int? _strLast;
  int? _strCurr;

  void initService() async {
    final androidConfig = FlutterBackgroundAndroidConfig (
      notificationTitle: "R2 Background Service",
      notificationText: "Listening for BLE signals",
      notificationImportance: AndroidNotificationImportance.normal,
    );
    bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
    debugPrint('$runtimeType : initialize background $success');
  }

  Future<void> startService() async {
    // Introduce a small delay to ensure device stability
    await Future.delayed(const Duration(seconds: 2));

    final device = await R2DBHelper().getDevice();
    if (device != null) {
      // Connect to the bonded device
      await _btModel.connectDevice(device.id,);

      // turn on the notification of device
      _btModel.sendData(device.id, [0x55, 0xB1, 0x03, 0x09, 0x00, 0x01, 0x10]);

      // Enable background execution
      final hasPermission =  await FlutterBackground.hasPermissions;
      final success = await FlutterBackground.enableBackgroundExecution();
      debugPrint('$runtimeType : permission $hasPermission ; enable background $success');

      try {
        _btModel.startListening(device.id, _onHelmetNotify,);
      } catch(e) {
        debugPrint('$runtimeType : Error starting listener $e');
      }
    }
  }

  Future<void> stopService() async {
    await FlutterBackground.disableBackgroundExecution();
  }

  /*
   * received the notification and handle it
   */
  void _onHelmetNotify(String data) {
    // "-" :0x0004
    // "‣︎" :0x0002
    // "+" :0x0004
    // "<" :0x0008
    // "✆" :0x0010
    // ">" :0x0020
    // "end" :0x0000
    debugPrint('_onHelmetNotify(): $data');
    R2BLECommand command = decodeBLEData(data);
    debugPrint('_onHelmetNotify(): ${command.toString()}');
    if (0 != command.instruction) {
      _strCurr = command.instruction;
      debugPrint('last instruction: $_strLast');
      debugPrint('current instruction: $_strCurr');
      if (4 == _strLast && 8 == _strCurr) {
        debugPrint('Condition met: Sending SMS');
        final sr = R2SosSender();
        sr.sendSos(data);
      } else {
        debugPrint('Condition not met.');
      }
      _strLast = _strCurr;
    } else {
      debugPrint('Ignored data: $data');
    }
  }
}
