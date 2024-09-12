import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:r2cyclingapp/connection/bt/bluetooth_manager.dart';
import 'package:r2cyclingapp/service/r2_background_service.dart';
import 'package:r2cyclingapp/usermanager/r2_user_manager.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_device.dart';

import 'package:r2cyclingapp/permission/permission_dialog.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';

import 'helmet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _btManager = BluetoothManager();
  final _service = R2BackgroundService();
  R2Device? _connectedDevice;
  bool _isUnbindMode = false;
  String emergencyContactStatus = '已关闭';
  Color emergencyContactColor = Colors.grey;
  File? _avatar;

  @override
  void initState() {
    super.initState();
    // what the hell WidgetsBinding is ? study it later
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _grantPermissions();
      _checkLoginStatus();
    });
    _service.setContext(context);
    _service.initService();
    _checkBondedDevice();
    _loadEmergencyContactStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAvatar();  // Reload the avatar whenever dependencies change (i.e., when returning to this screen)
  }

  @override
  void dispose() {
    // stop background service
    _service.stopService();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final manager = R2UserManager();
    final account = await manager.localAccount();
    if (account != null && account.avatarPath.isNotEmpty) {
      setState(() {
        _avatar = File(account.avatarPath);
      });
    } else {
      setState(() {
        _avatar = null;
      });
    }
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
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => PermissionDialog(),
        );
      }
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
    final isExpired = manager.expiredToken(token: token);
    debugPrint('$runtimeType : check login token?${null != token} account?${null != account} expired?$isExpired');
    if (token == null || account == null || true == isExpired) {
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
    final device = await _btManager.getDevice();
    if (device != null) {
      // Connect to the bonded device
      setState(() {
        _connectedDevice = device;
      });
      // start background service to handle the ble event
      _service.startService();
    }
  }

  /*
   * callback for Bluetooth Paring Screen
   * when BLE's connected, it will be executed.
   */
  Future<void> _helmetConnected(R2Device device) async {
    // later, it should analyze the brand name from id and name
    try {
      debugPrint('$runtimeType : device : ${device.id} - ${device.name}');
      setState(() {
        _connectedDevice = device;
      });
    } catch (error) {
      debugPrint('$runtimeType : $error');
    }
  }

  void _unbindDevice() async {
    if (_connectedDevice != null) {
      _service.stopService();
      _btManager.unbindDevice(_connectedDevice!);
      setState(() {
        _connectedDevice = null;
        _isUnbindMode = false;
      });
    }
  }

  /*
   * it shows a button for adding a smart helmet
   */
  Widget _addHelmetWidget() {
    return Align(
      alignment: Alignment.center,
      child:GestureDetector(
        onTap: () async {
          final isFound = await Navigator.pushNamed(
              context,
              '/bluetooth_pairing'
          );
          if (true == isFound) {
            await _checkBondedDevice();
          }
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

  /*
   *
   */
  Future<Widget> _leftNavigationButton() async {
    final manager = R2UserManager();
    final account = await manager.localAccount();
    final token  = await manager.readToken();
    if (null == token || null == account) {
      return IconButton(
          icon: const Icon(Icons.person, size:34.0),
          onPressed: () {
            _registerScreen();
          });
    } else {
      return IconButton(
          icon: FutureBuilder<Image>(
            future: account.getAvatar(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 30,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.error),
                );
              } else {
                return CircleAvatar(
                  radius: 30,
                  backgroundImage: snapshot.data?.image,
                );
              }
            },
          ),
          onPressed: () async {
            await Navigator.pushNamed(context, '/profile');
            _loadAvatar();
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
                    builder: (context) => const HelmetScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FutureBuilder<Widget>(
          future: _leftNavigationButton(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Loading indicator while waiting for the Future
            } else if (snapshot.hasError) {
              return IconButton(
                icon: const Icon(Icons.error, size: 34.0),
                onPressed: () {},
              );
            } else {
              return snapshot.data ?? const SizedBox.shrink();
            }
          },
        ),
        title: const Text('R2 Cycling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 34.0,),
            onPressed: () async {
              final isLoggedOut = await Navigator.pushNamed(context, '/settings');
              if (true == isLoggedOut) {
                _checkLoginStatus();
              }
              _loadAvatar();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          children: [
            _helmetWidget(),
            Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Divider(),
                    ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 30.0,
                            horizontal: 16.0
                        ),
                        leading: const Icon(Icons.group, size: 50.0,),
                        title: const Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                            child: Text('骑行对讲', style: TextStyle(fontSize: 24.0),)
                        ),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey[500],),
                        onTap: () async {
                          final manager = R2UserManager();
                          final group = await manager.localGroup();
                          if (mounted) {
                            if (null == group || 0 == group.gid) {
                              // If user is not in a group, navigate to GroupListScreen
                              Navigator.pushNamed(context, '/groupList');
                            } else {
                              // If user is in a group, navigate to GroupIntercomScreen
                              Navigator.pushNamed(context, '/intercom');
                            }
                          }
                        }
                    ),
                    const Divider(),
                    ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 30.0,
                            horizontal: 16.0
                        ),
                        leading: const Icon(Icons.sos, size: 50.0,),
                        title: const Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                            child: Text('紧急联络', style: TextStyle(fontSize: 24.0),)
                        ),
                        trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                emergencyContactStatus,
                                style: TextStyle(fontSize: 16.0, color: emergencyContactColor),
                              ),
                              const SizedBox(width: 10.0,),
                              Icon(Icons.chevron_right, color: Colors.grey[500],),
                            ]
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(context, '/emergencyContact');
                          _loadEmergencyContactStatus();
                          await Permission.sms.request();
                        }
                    ),
                    const Divider(),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}