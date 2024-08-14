import 'package:geolocator/geolocator.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';

import 'r2_sms.dart';

class R2SosSender {
  final R2DBHelper _dbHelper = R2DBHelper();

  Future<void> sendSos(String data) async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    String message = '【R2 Cycling】您的好友骑行时摔倒了，位置：${position.longitude},${position.latitude}';
    //String message = 'https://m.amap.com/navi/?dest=${position.longitude},${position.latitude}&destName=摔倒位置&hideRouteIcon=1&key=5aae26e3d543c89c1bfadf92925d4407&jscode=5b354fd17361c1a37d888a7a0ddf28cd';
    List<Map<String, dynamic>> contacts = await _dbHelper.getContacts();
    List<String> recipients = contacts.map((contact) => contact['phone'] as String).toList();

    for (String recipient in recipients) {
      print('send $recipient : $message');
      R2Sms.sendSMS(recipient, message);
    }
  }
}
