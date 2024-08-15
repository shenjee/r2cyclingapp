import 'package:geolocator/geolocator.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/database/r2_token_storage.dart';

import 'r2_sms.dart';

class R2SosSender {
  final R2DBHelper _dbHelper = R2DBHelper();

  Future<String?> _requestShortAddress(double longitude, double latitude) async {
    String? address;
    final token = await R2TokenStorage.getToken();
    final r2request = R2HttpRequest();
    final r2response = await r2request.sendRequest(
      token: token,
      api: 'locationEvent/fallDownReport',
      body: {
        'eventLat': '$latitude',
        'eventLon': '$longitude',
      },
    );

    if (true == r2response.success) {
      String resultData = r2response.result;
      address = 'http://r2cycling.imai.site/t/$resultData';
    } else {
      print('Failed to request group code: $r2response');
    }

    return address;
  }

  Future<void> sendSos(String data) async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings);
    final address = await _requestShortAddress(
        position.longitude, position.latitude);
    String message;
    if (null == address) {
      message = '【R2 Cycling】您的好友骑行时摔倒了，点击查看位置：${position
          .longitude},${position.latitude}';
    } else {
      message = '【R2 Cycling】您的好友骑行时摔倒了，点击查看位置：$address';
    }

    List<Map<String, dynamic>> contacts = await _dbHelper.getContacts();
    List<String> recipients = contacts.map((
        contact) => contact['phone'] as String).toList();

    for (String recipient in recipients) {
      print('send $recipient : $message');
      R2Sms.sendSMS(recipient, message);
    }
  }
}
