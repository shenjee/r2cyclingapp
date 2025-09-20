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

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';
import 'package:r2cyclingapp/connection/bt/r2_ble_command.dart';
import 'package:r2cyclingapp/emergency/sos_widget.dart';
import 'package:r2cyclingapp/emergency/r2_sos_sender.dart';
import 'package:r2cyclingapp/intercom/r2_intercom_engine.dart';
import 'package:r2cyclingapp/permission/r2_permission_manager.dart';

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

  Future<bool> initService() async {
    try {
      // Check and request permissions first
      final permissionManager = R2PermissionManager();
      final hasPermissions = await permissionManager.requestBackgroundPermissions();
      
      if (!hasPermissions) {
        debugPrint('$runtimeType : Background permissions not granted');
        return false;
      }
      
      debugPrint('$runtimeType : Background service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('$runtimeType : Error initializing background service: $e');
      return false;
    }
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

  Future<bool> startService() async {
    try {
      // Check permissions before starting
      final permissionManager = R2PermissionManager();
      if (!permissionManager.canStartBackgroundService()) {
        debugPrint('$runtimeType : Insufficient permissions to start background service');
        return false;
      }
      
      // Get bonded device
      final device = await R2DBHelper().getFirstDevice();
      if (device == null) {
        debugPrint('$runtimeType : No bonded device found');
        return false;
      }
      
      // Connect to the bonded device
      try {
        await _btModel.connectDevice(device.deviceId, deviceName: device.name);
        debugPrint('$runtimeType : Connected to device');
      } catch (e) {
        debugPrint('$runtimeType : Failed to connect to device: $e');
        return false;
      }
      
      // Turn on device notifications
      await _btModel.sendData(device.deviceId, [0x55, 0xB1, 0x03, 0x09, 0x00, 0x01, 0x10]);
      
      // Enable background execution
      final hasPermission = await FlutterBackground.hasPermissions;
      if (!hasPermission) {
        debugPrint('$runtimeType : Background permissions not available');
        return false;
      }
      
      final success = await FlutterBackground.enableBackgroundExecution();
      if (!success) {
        debugPrint('$runtimeType : Failed to enable background execution');
        return false;
      }
      
      // Start listening for helmet notifications
      try {
        _btModel.startListening(device.deviceId, _onHelmetNotify);
        debugPrint('$runtimeType : Background service started successfully');
        return true;
      } catch (e) {
        debugPrint('$runtimeType : Error starting listener: $e');
        await FlutterBackground.disableBackgroundExecution();
        return false;
      }
    } catch (e) {
      debugPrint('$runtimeType : Error starting background service: $e');
      return false;
    }
  }

  Future<void> stopService() async {
    try {
      // Disable background execution
      await FlutterBackground.disableBackgroundExecution();
      debugPrint('$runtimeType : Background service stopped');
    } catch (e) {
      debugPrint('$runtimeType : Error stopping background service: $e');
    }
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
