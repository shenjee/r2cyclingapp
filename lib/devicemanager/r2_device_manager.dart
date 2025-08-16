import 'package:flutter/material.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/devicemanager/r2_device.dart';

class R2DeviceManager {
  final _db = R2DBHelper();

  /// Save a device to the database
  Future<void> saveDevice(R2Device device) async {
    debugPrint('$runtimeType : Device saved: ${device.deviceId}');
    await _db.saveDevice(device);
  }

  /// Get device by deviceId from database
  Future<R2Device?> getDevice(String deviceId) async {
    final device = await _db.getDevice(deviceId);
    return device;
  }

  /// Delete a specific device by deviceId
  Future<int> deleteDevice(String deviceId) async {
    return await _db.deleteDevice(deviceId);
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
      await saveDevice(updatedDevice);
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

  /// Update device name
  /// 
  /// deviceId: the id of device to update
  /// value:   new device name
  Future<int> updateDeviceName({required String deviceId, String? value}) async {
    final device = await getDevice(deviceId);
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
      await _db.saveDevice(updatedDevice);
      return 0; // Success
    }
    return 1; // Failure
  }

  /// Update device BLE address
  /// 
  /// deviceId: the id of device to update
  /// value:   new BLE address
  Future<int> updateBleAddress({required String deviceId, String? value}) async {
    final device = await getDevice(deviceId);
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
      await _db.saveDevice(updatedDevice);
      return 0; // Success
    }
    return 1; // Failure
  }

  /// Update device Classic address
  /// 
  /// deviceId: the id of device to update
  /// value:   new Classic address
  Future<int> updateClassicAddress({required String deviceId, String? value}) async {
    final device = await getDevice(deviceId);
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
      await _db.saveDevice(updatedDevice);
      return 0; // Success
    }
    return 1; // Failure
  }
}