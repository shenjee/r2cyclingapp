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

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/connection/http/openapi/common_api.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';

import 'r2_sms.dart';

class R2SosSender {
  final _dbHelper = R2DBHelper();
  final _manager = R2UserManager();

  Future<String?> _requestShortAddress(
      double longitude, double latitude) async {
    String? address;
    final token = await _manager.readToken();
    final api = CommonApi.defaultClient();
    final resp = await api.fallDownReport(
      eventLat: '$latitude',
      eventLon: '$longitude',
      apiToken: token,
    );

    if ((resp['success'] ?? false) == true) {
      final dynamic result = resp['result'];
      if (result is Map<String, dynamic>) {
        final shortUrl = result['shortLinkId'];
        address = 'http://r2cycling.imai.site/t/$shortUrl';
      }
    } else {
      debugPrint('Failed to request group code: ${resp['message']}');
    }

    return address;
  }

  Future<void> sendSos(String data) async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
      timeLimit: Duration(seconds: 10),
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    debugPrint('$runtimeType : $position');

    final address =
        await _requestShortAddress(position.longitude, position.latitude);
    String message;
    if (null == address) {
      message =
          '【R2 Cycling】您的好友骑行时摔倒了，点击查看位置：${position.longitude},${position.latitude}';
    } else {
      message = '【R2 Cycling】您的好友骑行时摔倒了，点击查看位置：$address';
    }

    List<Map<String, dynamic>> contacts = await _dbHelper.getContacts();
    List<String> recipients =
        contacts.map((contact) => contact['phone'] as String).toList();

    for (String recipient in recipients) {
      debugPrint('send $recipient : $message');
      R2Sms.sendSMS(recipient, message);
    }
  }
}
