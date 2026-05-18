package com.scottenex.attendance

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onStart() {
        super.onStart()
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        // Create notification channels only on Android 8.0 and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            // Password Reset Channel
            val passwordResetChannel = NotificationChannel(
                "password_reset",
                "Password Reset Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for password reset requests"
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
            }
            notificationManager.createNotificationChannel(passwordResetChannel)

            // General Channel
            val generalChannel = NotificationChannel(
                "general",
                "General Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "General app notifications"
                enableLights(false)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(generalChannel)

            // Admin Alerts Channel
            val adminChannel = NotificationChannel(
                "admin_alerts",
                "Admin Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Important admin notifications"
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
            }
            notificationManager.createNotificationChannel(adminChannel)
        }
    }
}