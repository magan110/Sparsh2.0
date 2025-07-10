package com.example.learning2

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.learning2/location_service"
    private val TAG = "MainActivity"

    private var locationService: LocationForegroundService? = null
    private var isBound = false

    // Service connection object
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as LocationForegroundService.LocalBinder
            locationService = binder.getService()
            isBound = true
            Log.d(TAG, "Service connected")
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            locationService = null
            isBound = false
            Log.d(TAG, "Service disconnected")
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Bind to the service
        bindLocationService()

        // Set up method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLocationService" -> {
                    startLocationService()
                    result.success(true)
                }
                "stopLocationService" -> {
                    stopLocationService()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    val isRunning = locationService?.isRunning() ?: false
                    result.success(isRunning)
                }
                "getLastLocation" -> {
                    val location = locationService?.getLastLocation()
                    if (location != null) {
                        val locationMap = mapOf(
                            "latitude" to location.latitude,
                            "longitude" to location.longitude,
                            "timestamp" to location.time
                        )
                        result.success(locationMap)
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun bindLocationService() {
        Intent(this, LocationForegroundService::class.java).also { intent ->
            bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
        }
    }

    private fun startLocationService() {
        Log.d(TAG, "Starting location service from Flutter")

        // Save preference
        val prefs = getSharedPreferences("com.example.learning2.prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("background_service_enabled", true).apply()

        // Start the service
        Intent(this, LocationForegroundService::class.java).also { intent ->
            intent.action = "START_SERVICE"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        }
    }

    private fun stopLocationService() {
        Log.d(TAG, "Stopping location service from Flutter")

        // Save preference
        val prefs = getSharedPreferences("com.example.learning2.prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("background_service_enabled", false).apply()

        // Stop the service
        Intent(this, LocationForegroundService::class.java).also { intent ->
            intent.action = "STOP_SERVICE"
            startService(intent)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isBound) {
            unbindService(serviceConnection)
            isBound = false
        }
    }
}
