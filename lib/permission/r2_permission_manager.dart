import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background/flutter_background.dart';

class R2PermissionManager {
  static final R2PermissionManager _instance = R2PermissionManager._privateConstructor();
  R2PermissionManager._privateConstructor();
  factory R2PermissionManager() => _instance;

  // Track permission status
  bool _bluetoothPermissionGranted = false;
  bool _locationPermissionGranted = false;
  bool _microphonePermissionGranted = false;
  bool _backgroundPermissionGranted = false;
  bool _batteryOptimizationDisabled = false;

  // Getters for permission status
  bool get bluetoothPermissionGranted => _bluetoothPermissionGranted;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get microphonePermissionGranted => _microphonePermissionGranted;
  bool get backgroundPermissionGranted => _backgroundPermissionGranted;
  bool get batteryOptimizationDisabled => _batteryOptimizationDisabled;

  /// Check all required permissions for the app
  Future<Map<String, bool>> checkAllPermissions() async {
    final results = <String, bool>{};

    try {
      // Check Bluetooth permissions
      final bluetoothScan = await Permission.bluetoothScan.status;
      final bluetoothConnect = await Permission.bluetoothConnect.status;
      final bluetoothAdvertise = await Permission.bluetoothAdvertise.status;
      _bluetoothPermissionGranted = bluetoothScan.isGranted && 
                                   bluetoothConnect.isGranted && 
                                   bluetoothAdvertise.isGranted;
      results['bluetooth'] = _bluetoothPermissionGranted;

      // Check Location permissions
      final location = await Permission.location.status;
      final locationAlways = await Permission.locationAlways.status;
      _locationPermissionGranted = location.isGranted || locationAlways.isGranted;
      results['location'] = _locationPermissionGranted;

      // Check Microphone permission
      final microphone = await Permission.microphone.status;
      _microphonePermissionGranted = microphone.isGranted;
      results['microphone'] = _microphonePermissionGranted;

      // Check background execution permission
      _backgroundPermissionGranted = await FlutterBackground.hasPermissions;
      results['background'] = _backgroundPermissionGranted;

      // Check battery optimization (Android specific)
      final ignoreBatteryOptimizations = await Permission.ignoreBatteryOptimizations.status;
      _batteryOptimizationDisabled = ignoreBatteryOptimizations.isGranted;
      results['battery_optimization'] = _batteryOptimizationDisabled;

    } catch (e) {
      debugPrint('R2PermissionManager: Error checking permissions: $e');
    }

    return results;
  }

  /// Request Bluetooth permissions
  Future<bool> requestBluetoothPermissions() async {
    try {
      final permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ];

      final statuses = await permissions.request();
      _bluetoothPermissionGranted = statuses.values.every((status) => status.isGranted);
      
      if (!_bluetoothPermissionGranted) {
        debugPrint('R2PermissionManager: Bluetooth permissions denied');
      }
      
      return _bluetoothPermissionGranted;
    } catch (e) {
      debugPrint('R2PermissionManager: Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  /// Request Location permissions
  Future<bool> requestLocationPermissions() async {
    try {
      // First request basic location permission
      final locationStatus = await Permission.location.request();
      
      if (locationStatus.isGranted) {
        // Then request background location for better functionality
        final backgroundLocationStatus = await Permission.locationAlways.request();
        _locationPermissionGranted = backgroundLocationStatus.isGranted || locationStatus.isGranted;
      } else {
        _locationPermissionGranted = false;
      }
      
      if (!_locationPermissionGranted) {
        debugPrint('R2PermissionManager: Location permissions denied');
      }
      
      return _locationPermissionGranted;
    } catch (e) {
      debugPrint('R2PermissionManager: Error requesting location permissions: $e');
      return false;
    }
  }

  /// Request Microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      _microphonePermissionGranted = status.isGranted;
      
      if (!_microphonePermissionGranted) {
        debugPrint('R2PermissionManager: Microphone permission denied');
      }
      
      return _microphonePermissionGranted;
    } catch (e) {
      debugPrint('R2PermissionManager: Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Request background execution permissions
  Future<bool> requestBackgroundPermissions() async {
    try {
      // Initialize background service configuration
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "R2 Cycling Background Service",
        notificationText: "Monitoring helmet connection and emergency signals",
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'),
      );
      
      // Initialize flutter_background
      final initialized = await FlutterBackground.initialize(androidConfig: androidConfig);
      if (!initialized) {
        debugPrint('R2PermissionManager: Failed to initialize background service');
        return false;
      }
      
      // Check if we have permissions
      _backgroundPermissionGranted = await FlutterBackground.hasPermissions;
      
      if (!_backgroundPermissionGranted) {
        debugPrint('R2PermissionManager: Background execution permissions not granted');
      }
      
      return _backgroundPermissionGranted;
    } catch (e) {
      debugPrint('R2PermissionManager: Error requesting background permissions: $e');
      return false;
    }
  }

  /// Request battery optimization exemption (Android)
  Future<bool> requestBatteryOptimizationExemption() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      _batteryOptimizationDisabled = status.isGranted;
      
      if (!_batteryOptimizationDisabled) {
        debugPrint('R2PermissionManager: Battery optimization exemption denied');
      }
      
      return _batteryOptimizationDisabled;
    } catch (e) {
      debugPrint('R2PermissionManager: Error requesting battery optimization exemption: $e');
      return false;
    }
  }

  /// Request all critical permissions for the app
  Future<bool> requestAllCriticalPermissions() async {
    try {
      // Request permissions in logical order
      final bluetoothGranted = await requestBluetoothPermissions();
      final locationGranted = await requestLocationPermissions();
      final microphoneGranted = await requestMicrophonePermission();
      final backgroundGranted = await requestBackgroundPermissions();
      
      // Battery optimization is optional but recommended
      await requestBatteryOptimizationExemption();
      
      // Return true if all critical permissions are granted
      final allCriticalGranted = bluetoothGranted && locationGranted && microphoneGranted && backgroundGranted;
      
      if (allCriticalGranted) {
        debugPrint('R2PermissionManager: All critical permissions granted');
      } else {
        debugPrint('R2PermissionManager: Some critical permissions missing - Bluetooth: $bluetoothGranted, Location: $locationGranted, Microphone: $microphoneGranted, Background: $backgroundGranted');
      }
      
      return allCriticalGranted;
    } catch (e) {
      debugPrint('R2PermissionManager: Error requesting all permissions: $e');
      return false;
    }
  }

  /// Show permission rationale dialog
  Future<bool> showPermissionRationale(BuildContext context, String permissionType) async {
    final completer = Completer<bool>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(_getPermissionRationale(permissionType)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(true);
              },
              child: Text('Grant Permission'),
            ),
          ],
        );
      },
    );
    
    return completer.future;
  }

  String _getPermissionRationale(String permissionType) {
    switch (permissionType) {
      case 'bluetooth':
        return 'Bluetooth permission is required to connect and communicate with your smart helmet.';
      case 'location':
        return 'Location permission is required for emergency SOS functionality to send your location to emergency contacts.';
      case 'microphone':
        return 'Microphone permission is required for voice communication during group rides.';
      case 'background':
        return 'Background execution permission is required to monitor helmet signals and emergency situations even when the app is not active.';
      case 'battery_optimization':
        return 'Disabling battery optimization ensures the app can reliably monitor your helmet and respond to emergency situations.';
      default:
        return 'This permission is required for the app to function properly.';
    }
  }

  /// Open app settings for manual permission management
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('R2PermissionManager: Error opening app settings: $e');
    }
  }

  /// Check if critical permissions are sufficient for background service
  bool canStartBackgroundService() {
    return _bluetoothPermissionGranted && 
           _locationPermissionGranted && 
           _backgroundPermissionGranted;
  }

  /// Get permission status summary
  Map<String, dynamic> getPermissionSummary() {
    return {
      'bluetooth': _bluetoothPermissionGranted,
      'location': _locationPermissionGranted,
      'microphone': _microphonePermissionGranted,
      'background': _backgroundPermissionGranted,
      'battery_optimization': _batteryOptimizationDisabled,
      'can_start_background_service': canStartBackgroundService(),
    };
  }
}