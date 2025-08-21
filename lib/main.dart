// Copyright (c) 2025 RockRoad Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

import 'package:r2cyclingapp/emergency/emergency_contact_screen.dart';
import 'package:r2cyclingapp/screens/home_screen.dart';
import 'package:r2cyclingapp/screens/device_pairing_screen.dart';
import 'package:r2cyclingapp/group/group_list_screen.dart';
import 'package:r2cyclingapp/group/group_intercom_screen.dart';
import 'package:r2cyclingapp/login/user_register_screen.dart';
import 'package:r2cyclingapp/login/user_login_screen.dart';
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
      
      // Internationalization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Theme configuration
      theme: ThemeData(
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
        ),
      ),
      
      // Route configuration
      initialRoute: '/home',
      routes: {
        '/home':(context) => const HomeScreen(),
        '/register':(context) => const UserRegisterScreen(),
        '/login':(context) => const UserLoginScreen(),
        '/bluetooth_pairing':(context) => const DevicePairingScreen(),
        '/groupList':(context) => const GroupListScreen(),
        '/intercom':(context) => const GroupIntercomScreen(),
        '/emergencyContact':(context) => const EmergencyContactScreen(),
        '/settings':(context) => const SettingsScreen(),
        '/profile':(context) => const UserProfileScreen(),
      },
      
      // Debug configuration
      debugShowCheckedModeBanner: false,
    );
  }
}