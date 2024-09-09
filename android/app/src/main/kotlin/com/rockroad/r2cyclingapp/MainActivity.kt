package com.rockroad.r2cyclingapp
import android.util.Log
import android.telephony.SmsManager

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.BluetoothA2dp;
import android.bluetooth.BluetoothHeadset;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

class MainActivity: FlutterActivity() {
    private val CHANNEL = "r2_sms_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up a single MethodChannel for both SMS and Bluetooth profiles
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Handle the SMS sending logic
                "sendSMS" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    if (phoneNumber != null && message != null) {
                        val smsManager = SmsManager.getDefault()
                        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
                    }
                }

                // Handle enabling Bluetooth audio profiles
                "enableAudioProfiles" -> {
                    val deviceAddress = call.argument<String>("deviceAddress")
                    if (deviceAddress != null) {
                        val device: BluetoothDevice = BluetoothAdapter.getDefaultAdapter().getRemoteDevice(deviceAddress)
                        connectA2dp(device)
                        connectHeadset(device)
                        result.success(null)
                    } else {
                        result.error("INVALID_ADDRESS", "Device address is null", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // Method to connect A2DP (media audio profile)
    private fun connectA2dp(device: BluetoothDevice) {
        val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()

        bluetoothAdapter.getProfileProxy(this, object : BluetoothProfile.ServiceListener {
            override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
                if (profile == BluetoothProfile.A2DP) {
                    val a2dp = proxy as BluetoothA2dp
                    try {
                        // Use reflection to access the hidden connect() method
                        val connectMethod = BluetoothA2dp::class.java.getDeclaredMethod("connect", BluetoothDevice::class.java)
                        connectMethod.isAccessible = true
                        connectMethod.invoke(a2dp, device)
                        Log.d("Bluetooth", "A2DP connected to ${device.name}")
                    } catch (e: Exception) {
                        e.printStackTrace()
                        Log.e("Bluetooth", "Failed to connect A2DP", e)
                    }
                }
            }

            override fun onServiceDisconnected(profile: Int) {
                Log.d("Bluetooth", "A2DP disconnected")
            }
        }, BluetoothProfile.A2DP)
    }

    // Method to connect HFP (call audio profile)
    private fun connectHeadset(device: BluetoothDevice) {
        val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()

        bluetoothAdapter.getProfileProxy(this, object : BluetoothProfile.ServiceListener {
            override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
                if (profile == BluetoothProfile.HEADSET) {
                    val headset = proxy as BluetoothHeadset
                    try {
                        // Use reflection to access the hidden connect() method
                        val connectMethod = BluetoothHeadset::class.java.getDeclaredMethod("connect", BluetoothDevice::class.java)
                        connectMethod.isAccessible = true
                        connectMethod.invoke(headset, device)
                        Log.d("Bluetooth", "Headset connected to ${device.name}")
                    } catch (e: Exception) {
                        e.printStackTrace()
                        Log.e("Bluetooth", "Failed to connect Headset", e)
                    }
                }
            }

            override fun onServiceDisconnected(profile: Int) {
                Log.d("Bluetooth", "Headset disconnected")
            }
        }, BluetoothProfile.HEADSET)
    }
}
