import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ble
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';
// classic bluttoth
import 'package:permission_handler/permission_handler.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

class BluetoothPairingScreen extends StatefulWidget {
  final Function(DiscoveredDevice) onDeviceConnected;

  const BluetoothPairingScreen({super.key, required this.onDeviceConnected});

  @override
  State<BluetoothPairingScreen> createState() => _BluetoothPairingScreenState();
}

class _BluetoothPairingScreenState extends State<BluetoothPairingScreen> with TickerProviderStateMixin {
  final R2BluetoothModel _bluetoothModel = R2BluetoothModel();
  bool _isScanning = false;  // title
  String _title = '开始连接您的智能头盔';
  // ble
  DiscoveredDevice? connectedDevice;// classic bluetooth

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
    _bluetoothModel.stopScan();
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
      //startScanning();
      debugPrint('Permission granted');
    } else {
      debugPrint('Permissions not granted');
    }
  }

  void _addListener() {
    /*
    _bluetoothModel.scannedDevices.listen((devices) {
      setState(() {});
    });

    _bluetoothModel.connectedDevice.listen(
            (connectionState) {
              try {
                if (connectionState?.connectionState ==
                    DeviceConnectionState.connected) {
                  debugPrint('$runtimeType : device connected');
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              } catch (error) {
                debugPrint('$runtimeType : $error');
              }
    },
    onError: (error) {
      debugPrint('$runtimeType : ');
    });*/
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _title = '请选择您的智能头盔';
    });

    _bluetoothModel.scanDevices();
  }

  Future<void> _onDeviceSelected(DiscoveredDevice device) async {
    // stop bluetooth scanning
    _bluetoothModel.stopScan();
    _isScanning = false;
    _title = '正在连接您的智能头盔';
    setState(() {
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

    // Execute the code after the animation completes
    Future.delayed(const Duration(seconds: 3), () async {
      await widget.onDeviceConnected(device); // Notify the parent widget
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });

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
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 20.0),
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
            padding: const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
            child:_instructionItem('1', '确保手机蓝牙已开启'),
          ),
          const SizedBox(height: 8),
          Padding(
            padding:const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
            child:_instructionItem('2', '长按智能头盔的开机键，\n直至听到“配对”提示音'),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
            child:_instructionItem('3', '将手机紧靠您的智能头盔'),
          ),
        ],
    );
  }

  Widget _scanningWidget() {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        StreamBuilder<List<DiscoveredDevice>>(
            stream: _bluetoothModel.scannedDevices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                return Column(
                  children: snapshot.data!.map(
                          (device) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),  // Optional: Adds spacing between items
                              decoration: BoxDecoration(
                                color: const Color(0xFF539765),  // Set your desired background color here
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: ListTile(
                                textColor: Colors.white,
                                title: Text(device.name),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 16.0,
                                ),
                                trailing: Icon(Icons.chevron_right, color: Colors.grey[200]),
                                onTap: () => _onDeviceSelected(device),
                              ),
                            );
                          }).toList(),
                );
              } else {
                return const Text("正在扫描...");
              }
            }
        ),
      ],
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
              Icon(Icons.bluetooth, size: 36, color: Colors.grey[700]),
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
            _bluetoothModel.stopScan();
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