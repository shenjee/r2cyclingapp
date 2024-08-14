package com.rockroad.r2cyclingapp

import android.os.Bundle
import android.telephony.SmsManager
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "r2_sms_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Ensure flutterEngine is non-null
        val messenger = flutterEngine?.dartExecutor?.binaryMessenger
        if (messenger != null) {
            MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
                if (call.method == "sendSMS") {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    val smsManager = SmsManager.getDefault()
                    smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
        } else {
            // Handle the situation when messenger is null
            // This may happen if the Flutter engine is not yet initialized
            println("Flutter engine is not initialized.")
        }
    }
}
