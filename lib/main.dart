import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import 'package:r2cyclingapp/emergency/emergency_contact_screen.dart';
import 'package:r2cyclingapp/screens/home_screen.dart';
import 'package:r2cyclingapp/screens/bluetooth_pairing_screen.dart';
import 'package:r2cyclingapp/group/group_list_screen.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';
import 'package:r2cyclingapp/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBackground.initialize(
    androidConfig: const FlutterBackgroundAndroidConfig(
      notificationTitle: "Background Service",
      notificationText: "Listening for BLE signals",
      notificationImportance: AndroidNotificationImportance.Default,
    ),
  );
  runApp(const R2CyclingApp());
}

class R2CyclingApp extends StatelessWidget {
  const R2CyclingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R2 Cycling',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF539765)),
        useMaterial3: true,
      ),
      initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/bluetooth_pairing') {
            final args = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (context) {
                return BluetoothPairingScreen(onDeviceConnected: args['onDeviceConnected']);
              },
            );
          }
          // Define other routes here
          return MaterialPageRoute(builder: (context) => HomeScreen());
        },
      routes: {
        '/':(context) => HomeScreen(),
        '/register':(context) => UserRegisterScreen(),
        '/groupList':(context) => GroupListScreen(),
        '/emergencyContact':(context) => EmergencyContactScreen(),
        '/settings':(context) => SettingsScreen(),
      }
    );
  }
}