import 'package:flutter/material.dart';

import 'package:r2cyclingapp/connection/bt/bluetooth_manager.dart';
import 'package:r2cyclingapp/database/r2_device.dart';

class HelmetScreen extends StatefulWidget {

  const HelmetScreen({super.key});

  @override
  State<HelmetScreen> createState() => _HelmetScreenState();
}

class _HelmetScreenState extends State<HelmetScreen> {
  final _btManager = BluetoothManager();
  R2Device? _helmet;

  @override
  void initState() {
    super.initState();
    _fetchDevice();
    /*
    bleModel.connectDevice(widget.device.id).then((_) {
      // Successfully connected and initialized characteristic
    }).catchError((error) {
      print('Connection error: $error');
    });
     */
  }

  // Separate async method
  Future<void> _fetchDevice() async {
    R2Device? device = await _btManager.getDevice();
    if (device != null) {
      setState(() {
        _helmet = device;
      });
    }
  }

  void _sendDataAppConnection() {
    // App sends 0x55B10309000110
    // Left Light 0x55B10301000110
    _btManager.remote(HelmetRemoteOperation.appConnect);
  }

  void _volumeUp() {
    _btManager.remote(HelmetRemoteOperation.volumeUp);
  }

  void _volumeDown() {
    _btManager.remote(HelmetRemoteOperation.volumeDown);
  }

  void _leftLight() {
    // Right Light 0x55B10301000118
    _btManager.remote(HelmetRemoteOperation.leftLight);
  }

  void _rightLight() {
    // Right Light 0x55B1030100D0C9
    _btManager.remote(HelmetRemoteOperation.rightLight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helmet Control'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Helmet Info:', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Brand: ${_helmet!.brand}'),
            Text('ID: ${_helmet!.id}'),
            Text('Name: ${_helmet!.name}'),
            Text('BLE Address: ${_helmet!.bleAddress}'),
            Text('Classic Address: ${_helmet!.classicAddress}'),
            // control volume
            const SizedBox(height: 24),
            const Text('音量：', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _volumeDown(),
                  child: const Row(
                    children: [
                      Icon(Icons.volume_down),
                      Text('Volume Down'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _volumeUp(),
                  child: const Row(
                    children: [
                      Text('Volume Up'),
                      SizedBox(width: 5),
                      Icon(Icons.volume_up),
                    ],
                  ),
                ),
              ],
            ),
            // control light
            const SizedBox(height: 24),
            const Text('灯光：', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _leftLight(),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_left),
                      SizedBox(width: 8),
                      Text('Left Light'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _rightLight(),
                  child: const Row(
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