import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:r2cyclingapp/devicemanager/r2_device_manager.dart';
import 'package:r2cyclingapp/devicemanager/r2_device.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

class DevicePairingScreen extends StatefulWidget {

  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> with TickerProviderStateMixin {
  final _btManager = R2DeviceManager();
  Stream<List<R2Device>>? _scannedDevices;
  R2Device? _bondedDevice;

  bool _isScanning = false;  // title
  String _title = '';

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_title.isEmpty) {
      _title = AppLocalizations.of(context)!.startConnectHelmet;
    }
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

  /*
   * start scanning bluetooth devices
   */
  void _startScanning() {
    setState(() {
      _isScanning = true;
      _title = AppLocalizations.of(context)!.selectYourHelmet;
    });

    _scannedDevices = _btManager.scanDevices(brand: 'EH201');
  }

  /*
   * it responds to the selection of device
   * device - ble info, no classic bt address
   */
  Future<void> _onDeviceSelected(R2Device device) async {
    // stop bluetooth scanning
    _btManager.stopScan();
    setState(() {
      _isScanning = false;
      _title = AppLocalizations.of(context)!.connectingHelmet;
      _bondedDevice = device;
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

    // bind ble, and start pairing classic bt
    await _btManager.bindDevice(device, onBond: _helmetBonded);
  }

  /*
   * helmet is boned, then stop animation and pop off bluetooth pairing screen
   */
  void _helmetBonded(R2Device device) {
    if (mounted) {
      _animationController.stop();
      Navigator.of(context).pop(true);
    }
  }

  /*
   * Items of instruction guide, an item features a rounded number and
   * instruction content.
   * number - number
   * text - instruction content
   */
  Widget _instructionItem(String number, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppConstants.primaryColor200,
              width: 2.5,
            ),
            color: Colors.transparent,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppConstants.primaryColor200,
                fontSize: 22.0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
            text,
            style: const TextStyle(fontSize: 22.0),
        ),
      ],
    );
  }

  /*
   * Instruction board tells user what to be prepared before helmet pairing.
   */
  Widget _instructionWidget() {
    return Center(
      child:Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionItem('1', AppLocalizations.of(context)!.ensureBluetoothOn),
          const SizedBox(height: 50.0),
          _instructionItem('2', AppLocalizations.of(context)!.longPressHelmetButton),
          const SizedBox(height: 50.0),
         _instructionItem('3', AppLocalizations.of(context)!.bringPhoneClose),
        ],
      ),
    );
  }

  /*
   * scanning board, dynamically listing the devices scanned
   */
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
                      color: AppConstants.primaryColor,
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

  /*
   * An animation start when paring starts and stop when paring finishes,
   * let user know the process of pairing
   */
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

  /*
   * change the center of the screen in accordance with the status of binding
   */
  Widget _centerWidget() {
    Widget w;
    if (true == _isScanning) {
      w = _scanningWidget();
    } else if (_bondedDevice == null) {
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
            Navigator.of(context).pop(false);
            },
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child:Text(
                _title,
                style: const TextStyle(fontSize: 28.0),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 30.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.white,
              height: 420,
              child:_centerWidget(),
            ),
            const SizedBox(height: 100.0,),
            if (false == _isScanning && null == _bondedDevice)
              R2FlatButton(
                  text: AppLocalizations.of(context)!.startConnect,
                  onPressed: () {
                    _startScanning();
                  }),
          ]
      ),
    );
  }
}