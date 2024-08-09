import 'package:flutter/material.dart';
// ble
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';
// classic bluttoth
import 'package:permission_handler/permission_handler.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

class BluetoothPairingScreen extends StatefulWidget {
  final Function(DiscoveredDevice) onDeviceConnected;

  BluetoothPairingScreen({required this.onDeviceConnected});

  @override
  _BluetoothPairingScreenState createState() => _BluetoothPairingScreenState();
}

class _BluetoothPairingScreenState extends State<BluetoothPairingScreen> {
  final R2BluetoothModel _bluetoothModel = R2BluetoothModel();
  bool _isScanning = false;  // title
  String _title = '开始连接您的智能头盔';
  // ble
  DiscoveredDevice? connectedDevice;// classic bluetooth

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _addListener();
  }

  @override
  void dispose() {
    _bluetoothModel.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    // Request permissions
    var bluetoothStatus = await Permission.bluetooth.status;
    if (!bluetoothStatus.isGranted) {
      bluetoothStatus = await Permission.bluetooth.request();
    }

    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    if (!bluetoothScanStatus.isGranted) {
      bluetoothScanStatus = await Permission.bluetoothScan.request();
    }

    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    if (!bluetoothConnectStatus.isGranted) {
      bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    }

    var locationStatus = await Permission.locationWhenInUse.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.locationWhenInUse.request();
    }
    print('${bluetoothStatus.isGranted} ${bluetoothScanStatus.isGranted} ${bluetoothConnectStatus.isGranted} ${locationStatus.isGranted}');
    if (/*bluetoothStatus.isGranted && */bluetoothScanStatus.isGranted &&
        bluetoothConnectStatus.isGranted && locationStatus.isGranted) {
      //startScanning();
      print('Permission granted');
    } else {
      print('Permissions not granted');
    }
  }

  void _addListener() {
    _bluetoothModel.scannedDevices.listen((devices) {
      setState(() {});
    });
    _bluetoothModel.connectedDevice.listen((connectionState) {
      if (connectionState?.connectionState == DeviceConnectionState.connected) {
        Navigator.pop(context);
      }
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _title = '正在连接您的智能头盔';
    });

    _bluetoothModel.scanDevices();
  }


  void _connectToDevice(DiscoveredDevice device) async {
    setState(() {
      connectedDevice = device;
    });

    print('Connecting to ${device.name}');
    _bluetoothModel.connectDevice(device.id);
    widget.onDeviceConnected(device); // Notify the parent widget

    // After BLE connection, initiate Bluetooth Classic connection
  }

  Widget _instructionItem(String number, String text) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.0,
          backgroundColor: Colors.grey[500],
          child: Text(
            number,
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ],
    );
  }

  Widget _instructionWidget() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
            child:_instructionItem('1', '确保手机蓝牙已开启'),
          ),
          SizedBox(height: 8),
          Padding(
            padding:EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
            child:_instructionItem('2', '长按智能头盔的开机键，\n直至听到“配对”提示音'),
          ),
          SizedBox(height: 8),
          Padding(
            padding:EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
            child:_instructionItem('3', '将手机紧靠您的智能头盔'),
          ),
        ],
    );
  }

  Widget _scanningWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 48.0),
            SizedBox(width: 16.0),
            Icon(Icons.bluetooth, size: 48.0),
            SizedBox(width: 16.0),
            Icon(Icons.cyclone, size: 48.0),
          ],
        ),
        SizedBox(height: 16.0),
        StreamBuilder<List<DiscoveredDevice>>(
            stream: _bluetoothModel.scannedDevices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                return Column(
                  children: snapshot.data!.map((device) {
                    return ListTile(
                      title: Text(device.name),
                      subtitle: Text(device.id),
                      onTap: () => _connectToDevice(device),
                    );
                  }).toList(),
                );
              } else {
                return Text("正在扫描...");
              }
            }
        ),
      ],
    );
  }

  Widget _centerWidget() {
    Widget w;
    if (true == _isScanning) {
      w = _scanningWidget();
    } else {
      w = _instructionWidget();
    }

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: 34.0,),
          onPressed: () {
            Navigator.pop(context);
            },
        ),
      ),
      body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(30.0),
              child:Text(_title, style: TextStyle(fontSize: 28.0),textAlign: TextAlign.left,),
            ),
            Container(
              padding: EdgeInsets.all(0.0),
              color: Colors.grey[200],
              height: 400,
              child:_centerWidget(),
            ),
            SizedBox(height: 50.0,),
            R2FlatButton(text: '开始连接', onPressed: (){
              _startScanning();
            }),
          ]
      ),
    );
  }
}