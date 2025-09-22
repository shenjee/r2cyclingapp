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
import 'dart:async';

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
  // Use Zone to capture all exceptions
  runZonedGuarded<Future<void>>(() async {
    // Capture Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter error: ${details.exception}');
      // You can add logging or crash reporting here
    };
    
    // Initialize Flutter binding
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize services required by the app
    await _initServices();
    
    // Launch the app
    runApp(const R2CyclingApp());
  }, (error, stackTrace) {
    // Handle all uncaught async errors
    debugPrint('Uncaught exception: $error');
    debugPrint('Stack trace: $stackTrace');
    
    // Try to launch the app in safe mode
    runApp(const R2CyclingAppSafeMode());
  });
}

/// Initialize services required by the app
Future<void> _initServices() async {
  try {
    // Add services that need to be initialized when the app starts
    // For example: database, shared preferences, network client, etc.
    
    // Simulate initialization process
    await Future.delayed(const Duration(milliseconds: 100));
    
    debugPrint('App services initialized successfully');
  } catch (e) {
    debugPrint('Service initialization error: $e');
    // Rethrow the exception to be handled by the outer Zone
    rethrow;
  }
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

/// Safe mode application class, provides basic functionality when the main app crashes
class R2CyclingAppSafeMode extends StatelessWidget {
  const R2CyclingAppSafeMode({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R2 Cycling (Safe Mode)',
      theme: ThemeData(
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('R2 Cycling (Safe Mode)'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'App encountered a problem',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'The app encountered an error during startup. Please try restarting the app. If the problem persists, please contact the support team.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Try to restart the main app
                  try {
                    runApp(const R2CyclingApp());
                  } catch (e) {
                    // If still failing, stay in safe mode
                    debugPrint('Restart failed: $e');
                  }
                },
                child: const Text('Try Restart'),
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}