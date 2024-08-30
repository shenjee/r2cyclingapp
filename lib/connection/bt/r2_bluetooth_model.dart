import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:rxdart/rxdart.dart';

class R2BluetoothModel {
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

  late QualifiedCharacteristic _characteristic;
  // write service and characteristic
  final String _writeServiceID = "0000ffe5-0000-1000-8000-00805f9b34fb";
  final String _writeCharacteristicID = "0000ffe9-0000-1000-8000-00805f9b34fb";
  // read service and characteristic
  final String _readServcieID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String _readCharacteristicID = "0000ffe4-0000-1000-8000-00805f9b34fb";

  void scanDevices() {
    _scannedDevices.add([]);
    _scanHandler = _reactiveBle.scanForDevices(withServices: []).listen(
            (device) {
              debugPrint('$runtimeType found ble: ${device.id}-${device.name}');
              if (device.name.startsWith('EH201')) {
                final devices = List<DiscoveredDevice>.from(
                    _scannedDevices.value);
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

  Future<void> connectDevice(String deviceId) async {
    debugPrint('$runtimeType : connect device id: $deviceId');

    try {
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
                    serviceId: Uuid.parse(_writeServiceID),
                    characteristicId: Uuid.parse(_writeCharacteristicID),
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

  Future<void> sendData(String deviceId, List<int> data) async {
    debugPrint('$runtimeType : sending data to device: $deviceId');
    try {
      await _reactiveBle.writeCharacteristicWithoutResponse(
          QualifiedCharacteristic(
            characteristicId: Uuid.parse(_writeCharacteristicID),
            serviceId: Uuid.parse(_writeServiceID),
            deviceId: deviceId,
          ),
          value: data);
    } catch(e) {
      debugPrint('Error sending data: $e');
    }
  }

  /*
   *
   */
  void startListening(String deviceId, Function(String) onDataReceived) {
    try {
      final c = QualifiedCharacteristic(
        serviceId: Uuid.parse(_readServcieID),
        characteristicId: Uuid.parse(_readCharacteristicID),
        deviceId: deviceId,
      );
      _reactiveBle.subscribeToCharacteristic(c).listen((data) {
        //final receivedData = String.fromCharCodes(data);
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

  void dispose() async {
    await _scanHandler?.cancel();
    await _connectionHandler?.cancel();
    await _writeSubscription?.cancel();

    _scannedDevices.close();
    _connectedDevice.close();
    _reactiveBle.deinitialize();
  }
}