import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/devicemanager/r2_device.dart';
import '../connection/bt/r2_bluetooth_model.dart';

enum HelmetRemoteOperation {
  appConnect,
  leftLight,
  rightLight,
  volumeUp,
  volumeDown,
}

class R2DeviceManager {
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

  Future<R2Device?> getFirstDevice() async {
    final device = await R2DBHelper().getFirstDevice();
    return device;
  }

  /// Save a device to the database
  Future<void> saveDevice(R2Device device) async {
    debugPrint('$runtimeType : Device saved: ${device.deviceId}');
    await R2DBHelper().saveDevice(device);
  }

  /// Get device by deviceId from database
  Future<R2Device?> getDevice(String deviceId) async {
    final device = await R2DBHelper().getDevice(deviceId);
    return device;
  }

  /// Delete a specific device by deviceId
  Future<int> deleteDevice(String deviceId) async {
    return await R2DBHelper().deleteDevice(deviceId);
  }

  /// Update device name
  /// 
  /// deviceId: the id of device to update
  /// value:   new device name
  Future<int> updateDeviceName({required String deviceId, String? value}) async {
    final device = await R2DBHelper().getDevice(deviceId);
    if (device != null) {
      final updatedDevice = R2Device(
        deviceId: device.deviceId,
        mac: device.mac,
        model: device.model,
        brand: device.brand,
        name: value ?? device.name,
        bleAddress: device.bleAddress,
        classicAddress: device.classicAddress,
        imageUrl: device.imageUrl,
      );
      await R2DBHelper().saveDevice(updatedDevice);
      return 0; // Success
    }
    return 1; // Failure
  }

  /// Update device BLE address
  /// 
  /// deviceId: the id of device to update
  /// value:   new BLE address
  Future<int> updateBleAddress({required String deviceId, String? value}) async {
    final device = await R2DBHelper().getDevice(deviceId);
    if (device != null) {
      final updatedDevice = R2Device(
        deviceId: device.deviceId,
        mac: device.mac,
        model: device.model,
        brand: device.brand,
        name: device.name,
        bleAddress: value,
        classicAddress: device.classicAddress,
        imageUrl: device.imageUrl,
      );
      await R2DBHelper().saveDevice(updatedDevice);
      return 0; // Success
    }
    return 1; // Failure
  }

  /// Update device Classic address
  /// 
  /// deviceId: the id of device to update
  /// value:   new Classic address
  Future<int> updateClassicAddress({required String deviceId, String? value}) async {
    final device = await R2DBHelper().getDevice(deviceId);
    if (device != null) {
      final updatedDevice = R2Device(
        deviceId: device.deviceId,
        mac: device.mac,
        model: device.model,
        brand: device.brand,
        name: device.name,
        bleAddress: device.bleAddress,
        classicAddress: value,
        imageUrl: device.imageUrl,
      );
      await R2DBHelper().saveDevice(updatedDevice);
      return 0; // Success
    }
    return 1; // Failure
  }

  // Upload bond device information to server
  Future<int> requestBindDevice(R2Device device) async {
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.postRequest(
      api: 'api/member/bindDevice',
      token: token,
      body: {
        'hwDeviceId': device.deviceId,
      },
    );

    if (true == response.success) {
      debugPrint('$runtimeType : Cloud bind device: ${response.message}');
      final Map<String, dynamic> data = response.result;
      final imageUrl = data['modelPict'] ?? '';
      
      // Update device with imageUrl and save to database
      final updatedDevice = R2Device(
        deviceId: device.deviceId,
        mac: device.mac,
        model: device.model,
        brand: device.brand,
        name: device.name,
        bleAddress: device.bleAddress,
        classicAddress: device.classicAddress,
        imageUrl: imageUrl,
      );
      await R2DBHelper().saveDevice(updatedDevice);
    } else {
      debugPrint('$runtimeType : Request bind device failed: ${response.code}');
    }

    return 0;
  }

  // Remove bond device information from server
  Future<int> requestUnbindDevice(R2Device device) async {
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.postRequest(
      api: 'api/member/unBindDevice',
      token: token,
    );
    
    debugPrint('$runtimeType : Cloud unbind device: ${response.message}');
    
    return 0;
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
