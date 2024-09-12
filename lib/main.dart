import 'package:flutter/material.dart';

import 'package:r2cyclingapp/emergency/emergency_contact_screen.dart';
import 'package:r2cyclingapp/screens/home_screen.dart';
import 'package:r2cyclingapp/screens/bluetooth_pairing_screen.dart';
import 'package:r2cyclingapp/group/group_list_screen.dart';
import 'package:r2cyclingapp/group/group_intercom_screen.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';
import 'package:r2cyclingapp/settings/settings_screen.dart';
import 'package:r2cyclingapp/settings/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const R2CyclingApp());
}

class R2CyclingApp extends StatelessWidget {
  const R2CyclingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R2 Cycling',
      /*
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF539765)),
        useMaterial3: true,
      ),
       */
      initialRoute: '/',
      routes: {
        '/':(context) => const HomeScreen(),
        '/register':(context) => const UserRegisterScreen(),
        '/bluetooth_pairing':(context) => const BluetoothPairingScreen(),
        '/groupList':(context) => const GroupListScreen(),
        '/intercom':(context) => const GroupIntercomScreen(),
        '/emergencyContact':(context) => const EmergencyContactScreen(),
        '/settings':(context) => const SettingsScreen(),
        '/profile':(context) => const UserProfileScreen(),
      }
    );
  }
}