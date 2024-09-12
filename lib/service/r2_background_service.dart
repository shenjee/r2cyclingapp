import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';
import 'package:r2cyclingapp/connection/bt/r2_ble_command.dart';
import 'package:r2cyclingapp/emergency/sos_widget.dart';
import 'package:r2cyclingapp/emergency/r2_sos_sender.dart';
import 'package:r2cyclingapp/intercom/r2_intercom_engine.dart';

class R2BackgroundService {
  // Singleton pattern
  R2BackgroundService._privateConstructor();
  static final R2BackgroundService _instance = R2BackgroundService._privateConstructor();

  factory R2BackgroundService() {
    return _instance;
  }

  BuildContext? _context;
  // Method to set context from widget
  void setContext(BuildContext context) {
    _context = context;
  }

  final R2BluetoothModel _btModel = R2BluetoothModel();

  bool _isIntercomOn = false;

  // temporary usage to simulate the detection of a fall
  int? _intLast;
  int? _intCurr;

  void initService() async {
    const androidConfig = FlutterBackgroundAndroidConfig (
      notificationTitle: "R2 Background Service",
      notificationText: "Listening for BLE signals",
      notificationImportance: AndroidNotificationImportance.normal,
    );
    bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
    debugPrint('$runtimeType : initialize background $success');
  }

  /*
   * handle the sos instruction from helmet
   */
  _sos(R2BLECommand c) {
    _intCurr = c.instruction;
    debugPrint('last instruction: $_intLast');
    debugPrint('current instruction: $_intCurr');
    if (4 == _intLast && 8 == _intCurr) {
      debugPrint('Condition met: Sending SMS');
      Navigator.of(_context!).push(MaterialPageRoute(
        builder: (context) => SOSWidget(
          onCancel: () {
            Navigator.of(context).pop(); // Close the widget
          },
          onSend: () {
            final sr = R2SosSender();
            sr.sendSos('data');  // Send the SOS message
          },
        ),
        fullscreenDialog: true, // This ensures it's over any other screen
      ));
    } else {
      debugPrint('Condition not met.');
    }
    _intLast = _intCurr;
  }

  /*
   * handle intercom instruction from remote. 1st tap to stop pause,
   * resuming speaking, 2nd tap to pause speak.
   */
  _intercom(R2BLECommand c) {
    final r2intercom = R2IntercomEngine.getInstance();

    if (null != r2intercom) {
      // turn on/off speak
      debugPrint('$runtimeType : _intercom() pause $_isIntercomOn');
      r2intercom.pauseSpeak(_isIntercomOn);
      _isIntercomOn = !_isIntercomOn;
    }
  }

  Future<void> startService() async {
    // Introduce a small delay to ensure device stability
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
    debugPrint('$runtimeType : _onHelmetNotify(): $data');
    R2BLECommand command = decodeBLEData(data);
    switch(command.instruction) {
      case 0x04:
      case 0x08:
        // temporarily 1st tap 0x04 + 2nd tap 0x08 simulates the crashing signal
        _sos(command);
      case 0x10:
        _intercom(command);
      default:
        debugPrint('Ignored data: $data');
    }
  }
}
