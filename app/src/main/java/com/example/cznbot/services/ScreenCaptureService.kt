package com.example.cznbot.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.IBinder

class ScreenCaptureService : Service() {

    private var mediaProjection: MediaProjection? = null
    private val CHANNEL_ID = "CZNbotScreenCapture"

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val resultCode = intent?.getIntExtra("resultCode", 0) ?: 0
        val data = intent?.getParcelableExtra<Intent>("data")

        if (resultCode != 0 && data != null) {
            startForeground(1, createNotification())
            
            val projectionManager = getSystemService(MediaProjectionManager::class.java)
            mediaProjection = projectionManager.getMediaProjection(resultCode, data)
            
            // TODO: Setup VirtualDisplay and ImageReader for 1-second polling
        }
        
        return START_NOT_STICKY
    }

    private fun createNotification(): Notification {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "CZNbot Screen Capture",
            NotificationManager.IMPORTANCE_LOW
        )
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)

        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("CZNbot Running")
            .setContentText("Capturing screen...")
            // .setSmallIcon(R.mipmap.ic_launcher) // Add proper icon later
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaProjection?.stop()
    }
}
