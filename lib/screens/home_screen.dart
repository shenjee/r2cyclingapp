import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:r2cyclingapp/connection/bt/r2_bluetooth_model.dart';
import 'package:r2cyclingapp/connection/bt/r2_ble_command.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_device.dart';
import 'package:r2cyclingapp/emergency/r2_sos_sender.dart';

import 'package:r2cyclingapp/permission/permission_dialog.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';

import 'helmet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bleModel = R2BluetoothModel();
  R2Device? _connectedDevice;
  bool _isUnbindMode = false;
  String emergencyContactStatus = '已关闭';
  Color emergencyContactColor = Colors.grey;

  // temporary usage to simulate the detection of a fall
  int? _strLast;
  int? _strCurr;

  @override
  void initState() {
    super.initState();
    // what the hell WidgetsBinding is ? study it later
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _grantPermissions();
      _checkLoginStatus();
    });
    _checkBondedDevice();
    _loadEmergencyContactStatus();
  }

  /*
   * When launch the app at the first time ,
   * ask the user to grant the permissions.
   */
  void _grantPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (false == isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      await showDialog(
        context: context,
        builder: (BuildContext context) => PermissionDialog(),
      );
    }
  }

  /*
   * check the user token is available or not.
   * if it is available, do nothing;
   * if there is no token or the token is damaged, pop up registration screen to
   * let the user register/login to get the token;
   * if the token expires, request and newer the it.
   */
  Future<void> _checkLoginStatus() async {
    final manager = R2UserManager();
    final token = await manager.readToken();
    final account = await manager.localAccount();
    if (token == null || account == null) {
      _registerScreen();
    }
  }

  void _registerScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 1.0,
          child: UserRegisterScreen(),
        );
      },
    );
  }

  Future<void> _loadEmergencyContactStatus() async {
    final setting = await R2DBHelper().getSetting();
    setState(() {
      if (setting != null && setting['emergencyContactEnabled'] == 1) {
        emergencyContactStatus = '已开启';
        emergencyContactColor = const Color(0xFF539765);
      } else {
        emergencyContactStatus = '已关闭';
        emergencyContactColor = Colors.grey;
      }
    });
  }

  Future<void> _checkBondedDevice() async {
    final device = await R2DBHelper().getDevice();
    if (device != null) {
      // Connect to the bonded device
      await _bleModel.connectDevice(device.id,);
      setState(() {
        _connectedDevice = R2Device(brand: device.brand, id: device.id, name: device.name);
      });
      _startListen();
    }
  }

  /*
   * callback for Bluetooth Paring Screen
   * when BLE's connected, it will be executed.
   */
  void _helmetConnected(DiscoveredDevice device) async {
    // later, it should analyze the brand name from id and name
    final r2Device = R2Device(brand: 'na', id: device.id, name: device.name);
    debugPrint('HomeScreen() _helmetConnected device : ${device.id}-${device.name}');
    setState(() {
      _connectedDevice = r2Device;
    });
    await R2DBHelper().saveDevice(r2Device);
    _startListen();
  }

  void _startListen() {
    if (null != _connectedDevice) {
      _bleModel.sendData(_connectedDevice!.id, [0x55, 0xB1, 0x03, 0x09, 0x00, 0x01, 0x10]);
      _bleModel.startListening(_connectedDevice!.id, _onHelmetNotify);
    }
  }

  /*
   * received the notification and handle it
   */
  void _onHelmetNotify(String data) {
    // "-" :0x0004
    // "‣︎" :0x0002
    // "+" :0x0004
    // "<" :0x0008
    // "✆" :0x0010
    // ">" :0x0020
    // "end" :0x0000
    debugPrint('_onHelmetNotify(): $data');
    R2BLECommand command = decodeBLEData(data);
    debugPrint('_onHelmetNotify(): ${command.toString()}');
    if (0 != command.instruction) {
      _strCurr = command.instruction;
      debugPrint('last instruction: $_strLast');
      debugPrint('current instruction: $_strCurr');
      if (4 == _strLast && 8 == _strCurr) {
        debugPrint('Condition met: Sending SMS');
        final sr = R2SosSender();
        sr.sendSos(data);
      } else {
        debugPrint('Condition not met.');
      }
      _strLast = _strCurr;
    } else {
      debugPrint('Ignored data: $data');
    }
  }

  /*
   * it shows a button for adding a smart helmet
   */
  Widget _addHelmetWidget() {
    return Align(
      alignment: Alignment.center,
      child:GestureDetector(
        onTap: (){
          Navigator.pushNamed(
              context,
              '/bluetooth_pairing',
              arguments: {'onDeviceConnected':_helmetConnected}
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[500],
              child: Icon(Icons.add, size: 50, color: Colors.grey[200]),
            ),
            const SizedBox(height: 18.0),
            Text(
              '点击添加您的智能头盔',
              style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  void _unbindDevice() async {
    if (_connectedDevice != null) {
      await R2DBHelper().deleteDevice();
      setState(() {
        _connectedDevice = null;
        _isUnbindMode = false;
      });
    }
  }

  /*
   * it shows brief information of the bonded helmet
   */
  Widget _infoWidget() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          GestureDetector(
            onLongPress: () {
              setState(() {
                _isUnbindMode = true;
              });
            },
            onTap: () {
              if (false == _isUnbindMode) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HelmetScreen(
                          device: _connectedDevice!, bleModel: _bleModel,),
                  ),
                );
              }
            },
            child:Column(
              children: <Widget>[
                Image.asset('assets/images/y2red.png'),
                Text(_connectedDevice!.name),
              ]
            ),
          ),
        ]
    );
  }

  Widget _removeHelmetWidget() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:MainAxisAlignment.center,
        children: <Widget> [
          GestureDetector(
              onTap: () {
                setState(() {
                  _isUnbindMode = false;
                });
                },
              child:Column(
                  children: <Widget>[
                    Image.asset('assets/images/y2red.png', width: 250.0,),
                    TextButton(
                      onPressed: _unbindDevice,
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      child: const Text('解除绑定'),
                    ),
                  ],
              )
          ),
        ]
    );
  }

  /*
   * it controls the half-top are of the screen to be a button
   * for adding a helmet or a brief info of bonded helmet.
   */
  Widget _helmetWidget() {
    Widget w;
    if (null == _connectedDevice) {
      w = _addHelmetWidget();
    } else {
      if (true == _isUnbindMode) {
        w = _removeHelmetWidget();
      } else {
        w = _infoWidget();
      }
    }
    return Container(
      width: 360.0,
      height:300.0,
      child: w,
    );
  }

  /*
   * the item of the navigation list .
   */
  Widget _listItem(
      IconData data,
      String title,
      String subtitle,
      GestureTapCallback onTap,
      {Color subtitleColor = Colors.grey}
      ) {
    return InkWell(
      onTap: onTap,
      child:Container(
        height: 120.0,
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Padding(
                padding:const EdgeInsets.all(20.0),
                child:Icon(data, size: 50.0,)
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text(title,style:const TextStyle(fontSize: 24.0))],
            ),
            Expanded(
              child: Center(
                  child:Text(
                      subtitle,
                      style: TextStyle(fontSize: 16.0, color: subtitleColor),
                  )),
            ),
            Icon(Icons.keyboard_arrow_right, color: Colors.grey[500],),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //pd.show(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person, size:34.0),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        title: const Text('R2 Cycling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 34.0,),
            onPressed: () async {
              final _isLoggedOut = await Navigator.pushNamed(context, '/settings');
              if (true == _isLoggedOut) {
                _checkLoginStatus();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          children: [
            _helmetWidget(),
            const SizedBox(height: 24.0),
            ListView(
              shrinkWrap: true,
              children: [
                const Divider(),
                _listItem(
                    Icons.group, '骑行对讲', '',
                        () async {
                      final manager = R2UserManager();
                      final group = await manager.localGroup();
                      if (0 == group!.gid) {
                        // If user is not in a group, navigate to GroupListScreen
                        await Navigator.pushNamed(context, '/groupList');
                      } else {
                        // If user is in a group, navigate to GroupIntercomScreen
                        await Navigator.pushNamed(context, '/intercom');
                      }
                    }
                    ),
                const Divider(),
                _listItem(Icons.sos, '紧急联络', emergencyContactStatus,
                        () async {
                          await Navigator.pushNamed(context, '/emergencyContact');
                          _loadEmergencyContactStatus();
                          await Permission.sms.request();

                        },
                  subtitleColor: emergencyContactColor,
                ),
                const Divider(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}