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

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class R2Sms {
  static const MethodChannel _platform = MethodChannel('r2_sms_channel');

  static Future<void> sendSMS(String phoneNumber, String message) async {
    try {
      final Map<String, dynamic> params = <String, dynamic>{
        'phoneNumber': phoneNumber,
        'message': message,
      };
      await _platform.invokeMethod('sendSMS', params);
    } on PlatformException catch (e) {
      debugPrint("Failed to send SMS: '${e.message}'.");
    }
  }
}
