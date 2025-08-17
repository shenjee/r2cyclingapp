import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ble lib
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// classic bt lib
import 'package:flutter_blue_classic/flutter_blue_classic.dart';


class R2BluetoothModel {
  static const platform = MethodChannel('r2_sms_channel');

  // Singleton instance
  static final R2BluetoothModel _instance = R2BluetoothModel._internal();

  // Factory constructor to return the singleton instance
  factory R2BluetoothModel() {
    return _instance;
  }

  // Private constructor for internal use
  R2BluetoothModel._internal();

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

  late QualifiedCharacteristic _characteristic;
  // write service and characteristic
  final String _writeServiceID = "0000ffe5-0000-1000-8000-00805f9b34fb";
  final String _writeCharacteristicID = "0000ffe9-0000-1000-8000-00805f9b34fb";
  // read service and characteristic
  final String _readServcieID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String _readCharacteristicID = "0000ffe4-0000-1000-8000-00805f9b34fb";

  // classic bt
  final _classicBt = FlutterBlueClassic();

  final StreamController<Map<String, String>> _pairingController = StreamController.broadcast();
  Stream<Map<String, String>> get pairingStream => _pairingController.stream;

  // ble operations
  void scanDevices({String? brand}) {
    _scannedDevices.add([]);
    _scanHandler = _reactiveBle.scanForDevices(withServices: []).listen(
            (device) {
              debugPrint('$runtimeType found ble: ${device.id} ${device.name}');
              if (brand != null) {
                if (device.name.startsWith(brand)) {
                  final devices = List<DiscoveredDevice>.from(
                      _scannedDevices.value);
                  if (!devices.any((d) => d.id == device.id)) {
                    devices.add(device);
                    _scannedDevices.add(devices);
                  }
                }
              } else {
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

  // todo: deviceId is the address of BLE
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
   */
  static Future<void> _enableAudioProfiles(String deviceAddress) async {
    try {
      await platform.invokeMethod('enableAudioProfiles', {"deviceAddress": deviceAddress});
    } on PlatformException catch (e) {
      debugPrint("Failed to enable audio profiles: ${e.message}");
    }
  }

  Future<void> pairClassicBt(String name) async {
    // Get the last 6 characters (e.g. Helmet-39C5B8 in EH201-5BA3BB39C5B8)
    String? lastPart = name.substring(name.length - 6);

    if (lastPart.isNotEmpty) {
      _classicBt.scanResults.listen((device) async {
        // classic bluetooth scanned
        debugPrint('$runtimeType : bond state: ${device.bondState
            .name}, device type: ${device.type.name}');
        BluetoothConnection? connection;

        if (device.name!.startsWith('Helmet-$lastPart')) {
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