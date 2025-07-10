package com.example.learning2

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.location.Location
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class LocationForegroundService : Service() {
    private val TAG = "LocationService"
    private val NOTIFICATION_CHANNEL_ID = "location_channel"
    private val NOTIFICATION_ID = 1001
    
    private var isServiceRunning = false
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private var lastLocation: Location? = null
    
    // Binder for activity communication
    private val binder = LocalBinder()
    
    inner class LocalBinder : Binder() {
        fun getService(): LocationForegroundService = this@LocationForegroundService
    }
    
    override fun onBind(intent: Intent): IBinder {
        return binder
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        
        // Initialize location client
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        
        // Create location callback
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.lastLocation?.let { location ->
                    lastLocation = location
                    Log.d(TAG, "Location update: ${location.latitude}, ${location.longitude}")
                    
                    // Update notification with new location
                    updateNotification(location)
                    
                    // Send location to Flutter (if needed)
                    // This would be handled through a method channel or broadcast
                }
            }
        }
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service start command received")
        
        when (intent?.action) {
            "START_SERVICE" -> startLocationService()
            "STOP_SERVICE" -> stopLocationService()
        }
        
        // If service is killed, restart it
        return START_STICKY
    }
    
    private fun startLocationService() {
        if (isServiceRunning) return
        
        Log.d(TAG, "Starting location service")
        
        // Create notification channel for Android O and above
        createNotificationChannel()
        
        // Start as foreground service with notification
        val notification = createNotification(null)
        startForeground(NOTIFICATION_ID, notification)
        
        // Request location updates
        requestLocationUpdates()
        
        isServiceRunning = true
    }
    
    private fun stopLocationService() {
        Log.d(TAG, "Stopping location service")
        
        // Remove location updates
        fusedLocationClient.removeLocationUpdates(locationCallback)
        
        // Stop foreground service
        stopForeground(true)
        stopSelf()
        
        isServiceRunning = false
    }
    
    private fun requestLocationUpdates() {
        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, TimeUnit.MINUTES.toMillis(1))
            .setWaitForAccurateLocation(false)
            .setMinUpdateIntervalMillis(TimeUnit.MINUTES.toMillis(1))
            .setMaxUpdateDelayMillis(TimeUnit.MINUTES.toMillis(5))
            .build()
        
        try {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            Log.e(TAG, "Error requesting location updates", e)
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Location Service Channel",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Used for location tracking in background"
                enableLights(true)
                lightColor = Color.BLUE
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(location: Location?): Notification {
        // Create an intent to open the app when notification is tapped
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build the notification
        val notificationBuilder = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("SPARSH Location Service")
            .setContentText(if (location != null) 
                "Location: ${location.latitude.format(6)}, ${location.longitude.format(6)}" 
                else "Getting location...")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
        
        return notificationBuilder.build()
    }
    
    private fun updateNotification(location: Location) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notification = createNotification(location)
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
        
        if (isServiceRunning) {
            fusedLocationClient.removeLocationUpdates(locationCallback)
            isServiceRunning = false
        }
    }
    
    // Helper function to format double to specified decimal places
    private fun Double.format(digits: Int) = "%.${digits}f".format(this)
    
    // Public methods that can be called from Flutter
    fun isRunning(): Boolean = isServiceRunning
    
    fun getLastLocation(): Location? = lastLocation
}
