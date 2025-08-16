import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/devicemanager/r2_device.dart';
import 'r2_bluetooth_model.dart';

enum HelmetRemoteOperation {
  appConnect,
  leftLight,
  rightLight,
  volumeUp,
  volumeDown,
}

class BluetoothManager {
  static const platform = MethodChannel('r2_sms_channel');

  final _btModel = R2BluetoothModel();

  Stream<List<R2Device>> scanDevices({String? brand}) {
    // Start scanning BLE devices using the existing method in _btModel
    _btModel.scanDevices(brand: brand);

    // Convert the stream of List<DiscoveredDevice> to List<R2Device>
    return _btModel.scannedDevices.map((discoveredDevices) {
      return discoveredDevices.map((discoveredDevice) {
        // Map DiscoveredDevice to R2Device
        return R2Device(
          deviceId: discoveredDevice.id,
          mac: '',
          model: '',
          brand: brand ?? '',
          name: discoveredDevice.name.isNotEmpty ? discoveredDevice.name : "Unknown",
          bleAddress: discoveredDevice.id,
          classicAddress: null,
          imageUrl: '',
        );
      }).toList();
    });
  }

  void stopScan() {
    _btModel.stopScan();
  }

  Future<void> bindDevice(R2Device device, {required Function(R2Device) onBond}) async {
    // Listen to pairing events
    _btModel.pairingStream.listen((pairingInfo) async {
      String deviceName = pairingInfo['name']!;
      String deviceAddress = pairingInfo['address']!;
      debugPrint("Paired with classic bt : $deviceName $deviceAddress");

      device.classicAddress = deviceAddress;
      // save ble and bt classic
      await R2DBHelper().saveDevice(device);
      
      onBond(device);
    });

    if (device.name.isNotEmpty) {
      await _btModel.pairClassicBt(device.name);
    }
  }

  Future<void> unbindDevice(R2Device device) async {
    await R2DBHelper().deleteAllDevices();
    if (device.classicAddress.isNotEmpty) {
      bool unpaired = await _btModel.unpairClassicBt(device.classicAddress);
      if (unpaired) {
        debugPrint("Device successfully unpaired");
      } else {
        debugPrint("Failed to unpair the device");
      }
    }
  }

  Future<R2Device?> getDevice() async {
    final device = await R2DBHelper().getFirstDevice();
    return device;
  }

  Future<void> remote(HelmetRemoteOperation operation) async {
    final device = await R2DBHelper().getFirstDevice();
    switch(operation) {
      case HelmetRemoteOperation.appConnect:
        _btModel.sendData(device!.deviceId, [0x55, 0xB1, 0x03, 0x09, 0x00, 0x01, 0x10]);
      case HelmetRemoteOperation.rightLight:
        _btModel.sendData(device!.deviceId, [0x55, 0xB1, 0x03, 0x01, 0x00, 0x02, 0x1b]);
      case HelmetRemoteOperation.leftLight:
        _btModel.sendData(device!.deviceId, [0x55, 0xB1, 0x03, 0x01, 0x00, 0x01, 0x18]);
      case HelmetRemoteOperation.volumeUp:
        _btModel.sendData(device!.deviceId, [0x55, 0xB1, 0x03, 0x08, 0x00, 0x08, 0x18]);
      case HelmetRemoteOperation.volumeDown:
        _btModel.sendData(device!.deviceId, [0x55, 0xB1, 0x03, 0x08, 0x00, 0x09, 0x19]);
      default:
    }
  }
}
