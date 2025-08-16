import 'package:flutter/material.dart';
import 'dart:convert';
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

  /// Get the local device from database
  Future<R2Device?> localDevice() async {
    final device = await _db.getDevice();
    return device;
  }

  /// Delete all devices
  Future<int> deleteDevice() async {
    return await _db.deleteDevice();
  }

  /// Request device information from server
  Future<R2Device?> requestDeviceInfo() async {
    R2Device? device;
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.getRequest(
      api: 'device/getDevice',
      token: token,
    );

    if (true == response.success) {
      debugPrint('$runtimeType : Device info retrieved: ${response.message}');
      final Map<String, dynamic> data = response.result;
      
      // Create R2Device from API response
      device = R2Device(
        deviceId: data['hwDeviceId']?.toString() ?? '',
        mac: data['hwDeviceId']?.toString() ?? '',
        model: data['hwDeviceModelId']?.toString() ?? '',
        brand: data['manufacturerId']?.toString() ?? '',
        name: data['deviceName'] ?? 'Device ${data['hwDeviceId']?.toString() ?? ''}',
        bleAddress: data['bleAddress'],
        classicAddress: data['classicAddress'],
      );
      
      // Save device to local database
      await _db.saveDevice(device);
      
    } else {
      debugPrint('$runtimeType : Request device info failed: ${response.code}');
    }

    return device;
  }

  /// Update device name
  /// 
  /// deviceId: the id of device.
  ///          if it is not provided, default device is the local device.
  /// value:   new device name
  Future<int> updateDeviceName({String? deviceId, String? value}) async {
    if (null == deviceId) {
      // update local device's name
      final device = await localDevice();
      if (device != null) {
        final updatedDevice = R2Device(
          deviceId: device.deviceId,
          mac: device.mac,
          model: device.model,
          brand: device.brand,
          name: value ?? device.name,
          bleAddress: device.bleAddress,
          classicAddress: device.classicAddress,
        );
        await _db.saveDevice(updatedDevice);
        return 1; // Success
      }
      return 0;
    } else {
      // update specified device's name
      // TODO: Implement specific device update
      return 0;
    }
  }

  /// Update device BLE address
  /// 
  /// deviceId: the id of device.
  ///          if it is not provided, default device is the local device.
  /// value:   new BLE address
  Future<int> updateBleAddress({String? deviceId, String? value}) async {
    if (null == deviceId) {
      // update local device's BLE address
      final device = await localDevice();
      if (device != null) {
        final updatedDevice = R2Device(
          deviceId: device.deviceId,
          mac: device.mac,
          model: device.model,
          brand: device.brand,
          name: device.name,
          bleAddress: value,
          classicAddress: device.classicAddress,
        );
        await _db.saveDevice(updatedDevice);
        return 1; // Success
      }
      return 0;
    } else {
      // update specified device's BLE address
      // TODO: Implement specific device update
      return 0;
    }
  }

  /// Update device Classic address
  /// 
  /// deviceId: the id of device.
  ///          if it is not provided, default device is the local device.
  /// value:   new Classic address
  Future<int> updateClassicAddress({String? deviceId, String? value}) async {
    if (null == deviceId) {
      // update local device's Classic address
      final device = await localDevice();
      if (device != null) {
        final updatedDevice = R2Device(
          deviceId: device.deviceId,
          mac: device.mac,
          model: device.model,
          brand: device.brand,
          name: device.name,
          bleAddress: device.bleAddress,
          classicAddress: value,
        );
        await _db.saveDevice(updatedDevice);
        return 1; // Success
      }
      return 0;
    } else {
      // update specified device's Classic address
      // TODO: Implement specific device update
      return 0;
    }
  }

  /// Check if device is paired/connected
  Future<bool> isDeviceConnected() async {
    final device = await localDevice();
    if (device != null) {
      // Check if device has valid BLE or Classic address
      return (device.bleAddress.isNotEmpty || device.classicAddress.isNotEmpty);
    }
    return false;
  }

  /// Clear all device data
  Future<void> clearDeviceData() async {
    await deleteDevice();
  }
}