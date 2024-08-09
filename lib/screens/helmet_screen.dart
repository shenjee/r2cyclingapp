import 'package:flutter/material.dart';

import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';
import 'package:r2cyclingapp/database/r2_device.dart';

class HelmetScreen extends StatefulWidget {
  final R2Device device;
  final R2BluetoothModel bleModel;

  HelmetScreen({required this.device, required this.bleModel});

  @override
  _HelmetScreenState createState() => _HelmetScreenState();
}

class _HelmetScreenState extends State<HelmetScreen> {

  @override
  void initState() {
    super.initState();
    widget.bleModel.connectDevice(widget.device.id).then((_) {
      // Successfully connected and initialized characteristic
    }).catchError((error) {
      print('Connection error: $error');
    });
  }

  void _sendDataAppConnection() {
    // App sends 0x55B10309000110
    // Left Light 0x55B10301000110
    widget.bleModel.sendDataToHelmet(widget.device.id, [0x55, 0xB1, 0x03, 0x09, 0x00, 0x01, 0x10]);
  }

  void _sendDataLeftLight() {
    // Right Light 0x55B10301000118
    widget.bleModel.sendDataToHelmet(widget.device.id, [0x55, 0xB1, 0x03, 0x01, 0x00, 0x01, 0x18]);
  }

  void _sendDataRightLight() {
    // Right Light 0x55B1030100D0C9
    widget.bleModel.sendDataToHelmet(widget.device.id, [0x55, 0xB1, 0x03, 0x01, 0x00, 0x02, 0x1b]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Helmet Control'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Helmet Info:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Brand: ${widget.device.brand}'),
            Text('ID: ${widget.device.id}'),
            Text('Name: ${widget.device.name}'),

            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _sendDataLeftLight(),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_left),
                      SizedBox(width: 8),
                      Text('Left Light'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _sendDataRightLight(),
                  child: Row(
                    children: [
                      Text('Right Light'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}