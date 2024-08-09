import 'package:flutter_background/flutter_background.dart';
//import 'package:sms_advanced/sms_advanced.dart';
import 'package:geolocator/geolocator.dart';

import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';

class R2BackgroundService {
  final R2BluetoothModel _bluetoothModel = R2BluetoothModel();
  final R2DBHelper _dbHelper = R2DBHelper();

  Future<void> startService() async {
    await FlutterBackground.enableBackgroundExecution();
    _bluetoothModel.startListening((data) async {
      await _sendSms(data);
    });
  }

  Future<void> stopService() async {
    await FlutterBackground.disableBackgroundExecution();
  }

  Future<void> _sendSms(String data) async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    String message = 'Emergency! Location: ${position.latitude}, ${position.longitude}. Data: $data';
    List<Map<String, dynamic>> contacts = await _dbHelper.getContacts();
    List<String> recipients = contacts.map((contact) => contact['phone'] as String).toList();
/*
    SmsSender sender = SmsSender();
    for (String recipient in recipients) {
      SmsMessage sms = SmsMessage(recipient, message);
      sender.sendSms(sms);
    }

 */
  }
}
