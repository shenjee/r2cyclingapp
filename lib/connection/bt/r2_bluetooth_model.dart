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

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ble lib
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// classic bt lib
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
// import bluetooth config
import 'r2_bluetooth_config.dart';


class R2BluetoothModel {
  static const platform = MethodChannel('r2_sms_channel');

  // Singleton instance
  static final R2BluetoothModel _instance = R2BluetoothModel._internal();

  // Factory constructor to return the singleton instance
  factory R2BluetoothModel() {
    return _instance;
  }

  // Private constructor for internal use
  R2BluetoothModel._internal() {
    _initializeConfigs();
  }

  // Initialize Bluetooth configurations
  Future<void> _initializeConfigs() async {
    await BluetoothConfigManager().loadConfigurations();
    _deviceConfigs = BluetoothConfigManager().deviceConfigs;
  }

  // List of device configurations
  List<BluetoothDeviceConfig> _deviceConfigs = [];

  // ble
  final FlutterReactiveBle _reactiveBle = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanHandler;
  StreamSubscription<ConnectionStateUpdate>? _connectionHandler;
  StreamSubscription<List<int>>? _writeSubscription;

  final _scannedDevices = BehaviorSubject<List<DiscoveredDevice>>.seeded([]);
  final _connectedDevice = BehaviorSubject<ConnectionStateUpdate?>.seeded(null);
  final BehaviorSubject<List<int>> _receivedData = BehaviorSubject<List<int>>();


  Stream<List<DiscoveredDevice>> get scannedDevices => _scannedDevices.stream;
  Stream<ConnectionStateUpdate?> get connectedDevice => _connectedDevice.stream;
  Stream<List<int>> get receivedData => _receivedData.stream;

  // Current device configuration
  BluetoothDeviceConfig? _currentConfig;

  // classic bt
  final _classicBt = FlutterBlueClassic();

  final StreamController<Map<String, String>> _pairingController = StreamController.broadcast();
  Stream<Map<String, String>> get pairingStream => _pairingController.stream;

  // ble operations
  void scanDevices() {
    _scannedDevices.add([]);
    _scanHandler = _reactiveBle.scanForDevices(withServices: []).listen(
            (device) {
              debugPrint('$runtimeType found ble: ${device.id} ${device.name}');
              
              // Check if device name matches any of our configured devices
              bool isMatchingDevice = false;
              for (var config in _deviceConfigs) {
                if (device.name.startsWith(config.name)) {
                  isMatchingDevice = true;
                  break;
                }
              }
              
              if (_deviceConfigs.isEmpty || isMatchingDevice) {
                final devices = List<DiscoveredDevice>.from(_scannedDevices.value);
                if (!devices.any((d) => d.id == device.id)) {
                  devices.add(device);
                  _scannedDevices.add(devices);
                }
              }
            },
        onError:(error) {
          debugPrint('$runtimeType : scan error: $error');
        });
  }

  void stopScan() {
    _scanHandler?.cancel();
    _scanHandler = null;
  }

  Future<void> connectDevice(String deviceId, {String? deviceName}) async {
    debugPrint('$runtimeType : connect device id: $deviceId');

    try {
      // Find the appropriate configuration for this device
      if (deviceName != null) {
        for (var config in _deviceConfigs) {
          if (deviceName.startsWith(config.name)) {
            _currentConfig = config;
            break;
          }
        }
      }
      
      // If no configuration found, use the first one as default (if available)
      if (_currentConfig == null && _deviceConfigs.isNotEmpty) {
        _currentConfig = _deviceConfigs.first;
      }
      
      // If still no configuration, log error and return
      if (_currentConfig == null) {
        debugPrint('$runtimeType : No device configuration found for $deviceName');
        return;
      }

      _connectionHandler = _reactiveBle.connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10))
          .listen(
              (update) {
            _connectedDevice.add(update);
            if (update.connectionState == DeviceConnectionState.connected) {
              debugPrint('$runtimeType : device $deviceId connected');
              _writeSubscription = _reactiveBle.subscribeToCharacteristic(
                  QualifiedCharacteristic(
                    serviceId: Uuid.parse(_currentConfig!.writeService),
                    characteristicId: Uuid.parse(_currentConfig!.writeCharacteristic),
                    deviceId: deviceId,
                  )).listen((data) {
                _receivedData.add(data);
              });
            }
          },
          onError: (error) {
            debugPrint('$runtimeType : connect to device error: $error');
          }
      );
    } catch (error) {
      debugPrint('$runtimeType : $error');
    }
  }

  // deviceId is the address of BLE
  Future<void> sendData(String deviceId, List<int> data) async {
    if (_currentConfig == null) {
      debugPrint('$runtimeType : No device configuration available');
      return;
    }
    
    debugPrint('$runtimeType : sending data to device: $deviceId');
    try {
      await _reactiveBle.writeCharacteristicWithoutResponse(
          QualifiedCharacteristic(
            characteristicId: Uuid.parse(_currentConfig!.writeCharacteristic),
            serviceId: Uuid.parse(_currentConfig!.writeService),
            deviceId: deviceId,
          ),
          value: data);
    } catch(e) {
      debugPrint('Error sending data: $e');
    }
  }

  /*
   * Start listening for data from the device
   */
  void startListening(String deviceId, Function(String) onDataReceived) {
    if (_currentConfig == null) {
      debugPrint('$runtimeType : No device configuration available');
      return;
    }
    
    try {
      final c = QualifiedCharacteristic(
        serviceId: Uuid.parse(_currentConfig!.readService),
        characteristicId: Uuid.parse(_currentConfig!.readCharacteristic),
        deviceId: deviceId,
      );
      _reactiveBle.subscribeToCharacteristic(c).listen((data) {
        final receivedData = _bytesToHex(data);
        onDataReceived(receivedData);
      });
    } catch (e) {
      debugPrint('$runtimeType : ble notification listener $e');
    }
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  // classic bt operations

  /*
   * enable A2dp and Headset profiles
   
  static Future<void> _enableAudioProfiles(String deviceAddress) async {
    try {
      await platform.invokeMethod('enableAudioProfiles', {"deviceAddress": deviceAddress});
    } on PlatformException catch (e) {
      debugPrint("Failed to enable audio profiles: ${e.message}");
    }
  }
  */

  Future<void> pairClassicBt(String name) async {
    // Get the last 6 characters (e.g. Helmet-39C5B8 in EH201-5BA3BB39C5B8)
    String? lastPart = name.substring(name.length - 6);
    
    // Find the appropriate configuration for this device
    for (var config in _deviceConfigs) {
      if (name.startsWith(config.name)) {
        _currentConfig = config;
        break;
      }
    }
    
    // If no configuration found, use the first one as default (if available)
    if (_currentConfig == null && _deviceConfigs.isNotEmpty) {
      _currentConfig = _deviceConfigs.first;
    }
    
    String classicBtPrefix = _currentConfig?.classicBtPrefix ?? 'Helmet';

    if (lastPart.isNotEmpty) {
      _classicBt.scanResults.listen((device) async {
        // classic bluetooth scanned
        debugPrint('$runtimeType : bond state: ${device.bondState
            .name}, device type: ${device.type.name}');
        
        if (device.name!.startsWith('$classicBtPrefix-$lastPart')) {
          // stop scanning classic bt
          _classicBt.stopScan();
          // bond device
          final b = await _classicBt.bondDevice(device.address);
          debugPrint('$runtimeType : ${device.address} bonded? $b');
          _pairingController.add({'name': device.name!, 'address': device.address});

          // connect to classic bt
          /*
           * when i use connect method, the ble read service always failed to
           * start.
           * so i try bondDevice method, it seems to work well.
          try {
            connection = await _classicBt.connect(device.address);
            if (connection != null && connection.isConnected) {
              debugPrint('$runtimeType : classic ${device.name} ${device
                  .address} connected');
              _enableAudioProfiles(device.address);

              // Add a delay to ensure Classic Bluetooth is stable before starting BLE
              await Future.delayed(const Duration(seconds: 1));
            }
          } catch (e) {
            debugPrint('$runtimeType : connecting to classic failed $e');
          }  */
        }
      });

      _classicBt.startScan();
    }
  }

  /*
   * Method to unpair a classic bluetooth device
   */
  Future<bool> unpairClassicBt(String deviceAddress) async {
    try {
      final bool result = await platform.invokeMethod('unpairDevice', {"deviceAddress": deviceAddress});
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to unpair device: ${e.message}");
      return false;
    }
  }

  // database operations

  void dispose() async {
    await _scanHandler?.cancel();
    await _connectionHandler?.cancel();
    await _writeSubscription?.cancel();

    _pairingController.close();
    _scannedDevices.close();
    _connectedDevice.close();
    _reactiveBle.deinitialize();
  }
}