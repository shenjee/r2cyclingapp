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

class R2BLECommand {
  final String header;
  final String commandType;
  final int length;
  final int version;
  final int instruction;
  final double voltage;
  final int batteryPercentage;
  final String crc;

  R2BLECommand({
    required this.header,
    required this.commandType,
    required this.length,
    required this.version,
    required this.instruction,
    required this.voltage,
    required this.batteryPercentage,
    required this.crc,
  });

  @override
  String toString() {
    return 'BLECommand(header: $header, commandType: $commandType, length: $length, version: $version, instruction: $instruction, voltage: $voltage, batteryPercentage: $batteryPercentage, crc: $crc)';
  }
}

R2BLECommand decodeBLEData(String data) {
  // Ensure the data is in the correct format
  String header = data.substring(0, 2);
  String commandType = data.substring(2, 4);
  int length = int.parse(data.substring(4, 6), radix: 16);
  if (length == 6 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(data)) {
    // Parse the values from the data string
    int version = int.parse(data.substring(6, 8), radix: 16);
    int instruction = int.parse(data.substring(8, 12), radix: 16);
    double voltage = int.parse(data.substring(12, 16), radix: 16) / 100.0;
    int batteryPercentage = int.parse(data.substring(16, 18), radix: 16);
    String crc = data.substring(18, 20);

    // Create and return the BLECommand object
    return R2BLECommand(
      header: header,
      commandType: commandType,
      length: length,
      version: version,
      instruction: instruction,
      voltage: voltage,
      batteryPercentage: batteryPercentage,
      crc: crc,
    );
  } else {
    return R2BLECommand(
      header: header,
      commandType: commandType,
      length: length,
      version: 0,
      instruction: 0x00,
      voltage: 0,
      batteryPercentage: 0,
      crc: 'na',
    );
  }
}