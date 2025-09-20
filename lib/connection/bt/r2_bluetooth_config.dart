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

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BluetoothDeviceConfig {
  final String manufacturer;
  final String name;
  final String writeService;
  final String writeCharacteristic;
  final String readService;
  final String readCharacteristic;
  final String classicBtPrefix;

  BluetoothDeviceConfig({
    required this.manufacturer,
    required this.name,
    required this.writeService,
    required this.writeCharacteristic,
    required this.readService,
    required this.readCharacteristic,
    required this.classicBtPrefix,
  });

  factory BluetoothDeviceConfig.fromJson(Map<String, dynamic> json) {
    return BluetoothDeviceConfig(
      manufacturer: json['manufacturer'],
      name: json['name'],
      writeService: json['write_service'],
      writeCharacteristic: json['write_characteristic'],
      readService: json['read_service'],
      readCharacteristic: json['read_characteristic'],
      classicBtPrefix: json['classic_bt_prefix'],
    );
  }
}

class BluetoothConfigManager {
  static final BluetoothConfigManager _instance = BluetoothConfigManager._internal();
  
  factory BluetoothConfigManager() {
    return _instance;
  }
  
  BluetoothConfigManager._internal();
  
  List<BluetoothDeviceConfig> _deviceConfigs = [];
  
  Future<void> loadConfigurations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/configs/bluetooth_devices.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _deviceConfigs = (jsonData['devices'] as List)
          .map((deviceJson) => BluetoothDeviceConfig.fromJson(deviceJson))
          .toList();
    } catch (e) {
      print('Error loading Bluetooth configurations: $e');
      // Initialize with default configuration if loading fails
      _deviceConfigs = [
        BluetoothDeviceConfig(
          manufacturer: 'EH201',
          name: 'EH201',
          writeService: '0000ffe5-0000-1000-8000-00805f9b34fb',
          writeCharacteristic: '0000ffe9-0000-1000-8000-00805f9b34fb',
          readService: '0000ffe0-0000-1000-8000-00805f9b34fb',
          readCharacteristic: '0000ffe4-0000-1000-8000-00805f9b34fb',
          classicBtPrefix: 'Helmet',
        )
      ];
    }
  }
  
  List<BluetoothDeviceConfig> get deviceConfigs => _deviceConfigs;
  
  BluetoothDeviceConfig? getConfigByName(String name) {
    try {
      return _deviceConfigs.firstWhere(
        (config) => name.startsWith(config.name),
      );
    } catch (e) {
      return null;
    }
  }
}