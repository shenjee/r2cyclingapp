import 'package:flutter/material.dart';

import 'package:r2cyclingapp/connection/bt/bluetooth_manager.dart';
import 'package:r2cyclingapp/database/r2_device.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

class BluetoothPairingScreen extends StatefulWidget {
  final Function(R2Device) onDeviceConnected;

  const BluetoothPairingScreen({super.key, required this.onDeviceConnected});

  @override
  State<BluetoothPairingScreen> createState() => _BluetoothPairingScreenState();
}

class _BluetoothPairingScreenState extends State<BluetoothPairingScreen> with TickerProviderStateMixin {
  final _btManager = BluetoothManager();
  Stream<List<R2Device>>? _scannedDevices;

  bool _isScanning = false;  // title
  String _title = '开始连接您的智能头盔';
  // ble
  R2Device? connectedDevice;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    debugPrint('${bluetoothStatus.isGranted} ${bluetoothScanStatus.isGranted} ${bluetoothConnectStatus.isGranted} ${locationStatus.isGranted}');
    if (/*bluetoothStatus.isGranted && */bluetoothScanStatus.isGranted &&
        bluetoothConnectStatus.isGranted && locationStatus.isGranted) {
      debugPrint('Permission granted');
    } else {
      debugPrint('Permissions not granted');
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _title = '请选择您的智能头盔';
    });

    _scannedDevices = _btManager.scanDevices(brand: 'EH201');
  }

  Future<void> _onDeviceSelected(R2Device device) async {
    // stop bluetooth scanning
    _btManager.stopScan();
    setState(() {
      _isScanning = false;
      _title = '正在连接您的智能头盔';
      connectedDevice = device;
    });

    // Initialize the animation controller for twinkling effect
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        _animationController.forward();
      }
    });

    // bind device
    await _btManager.bindDevice(device, onBond: _helmetBonded);
  }

  void _helmetBonded(R2Device device) {
    if (mounted) {
      _animationController.stop();
      Navigator.of(context).pop(true);
    }
  }

  Widget _instructionItem(String number, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 22.0,
          backgroundColor: Colors.grey[500],
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
        const SizedBox(width: 16),
        Text(
            text,
            style: const TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }

  Widget _instructionWidget() {
    return Center(
      child:Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionItem('1', '确保手机蓝牙已开启'),
          const SizedBox(height: 30),
          _instructionItem('2', '长按智能头盔的开机键，\n直至听到“配对”提示音'),
          const SizedBox(height: 30),
         _instructionItem('3', '将手机紧靠您的智能头盔'),
        ],
      ),
    );
  }

  Widget _scanningWidget() {
    return Expanded(
      child:StreamBuilder<List<R2Device>>(
          stream: _scannedDevices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for the first data
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Show an error message if something went wrong
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show a message if the list is empty
              return const Center(child: Text('No devices found'));
            } else {
              final devices = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF539765),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                      textColor: Colors.white,
                      title: Text(device.name),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white),
                      onTap: () {
                        // Handle device tap action
                        _onDeviceSelected(device);
                      },
                    ),
                  );
                },
              );
            }
          }
      ),
    );
  }

  Widget _connectingWidget() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smartphone, size: 44, color: Colors.grey[700]),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // fuck it, stupid flutter , u have to ... use sized box.
              const SizedBox(height:140.0),
              Icon(Icons.bluetooth_searching, size: 36, color: Colors.grey[700]),
              const SizedBox(height: 8.0,),
              AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Row(
                      children: [
                        for (int i = 0; i < 10; i++) ...[
                          Opacity(
                            opacity: _animation.value > i*0.1? 1.0:0.0,
                            child: Container(
                              width: 10,
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              color: Colors.grey[700],
                            ),
                          )
                        ],
                      ],
                    );}
              ),
            ],
          ),
          const SizedBox(width: 8.0),
          Image.asset('assets/icons/cycling_helmet.png', width: 52.0, height: 52.0),
        ],
      ),
    );
  }

  Widget _centerWidget() {
    Widget w;
    if (true == _isScanning) {
      w = _scanningWidget();
    } else if (connectedDevice == null) {
      w = _instructionWidget();
    } else {
      w = _connectingWidget();
    }

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 34.0,),
          onPressed: () {
            // stop device scanning
            _animationController.stop();
            Navigator.of(context).pop(false);
            },
        ),
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child:Text(
                _title,
                style: const TextStyle(fontSize: 28.0),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.grey[200],
              height: 400,
              child:_centerWidget(),
            ),
            const SizedBox(height: 50.0,),
            if (false == _isScanning && null == connectedDevice)
              R2FlatButton(
                  text: '开始连接',
                  onPressed: () {
                    _startScanning();
                  }),
          ]
      ),
    );
  }
}