package com.example.learning2

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.content.SharedPreferences

class BootCompletedReceiver : BroadcastReceiver() {
    private val TAG = "BootCompletedReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Boot completed received")

            // NEVER auto-start the service after boot
            // User must manually start the service from the app
            Log.d(TAG, "Service not started automatically - requires manual activation")

            // Reset the preference to ensure it's always manual
            val prefs: SharedPreferences = context.getSharedPreferences("com.example.learning2.prefs", Context.MODE_PRIVATE)
            prefs.edit().putBoolean("background_service_enabled", false).apply()
        }
    }
}
