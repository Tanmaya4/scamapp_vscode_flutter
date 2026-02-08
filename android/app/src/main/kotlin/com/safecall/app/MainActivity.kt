package com.safecall.app

import android.Manifest
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.MediaRecorder
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.telecom.TelecomManager
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.safecall/native_bridge"
        private const val EVENT_CHANNEL = "com.safecall/call_events"
        private const val NOTIFICATION_CHANNEL_ID = "safecall_foreground"
        private const val FOREGROUND_NOTIFICATION_ID = 1001
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    // Call monitoring
    private var telephonyManager: TelephonyManager? = null
    private var phoneStateListener: PhoneStateListener? = null
    private var telephonyCallback: Any? = null // TelephonyCallback for API 31+
    private var isCallMonitoringActive = false

    // Audio monitoring
    private var audioRecord: AudioRecord? = null
    private var isAudioMonitoring = false
    private var audioThread: Thread? = null

    // Audio manager for mute
    private var audioManager: AudioManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        createNotificationChannel()

        // ── Method Channel ──────────────────────────────────────
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                // Call Monitoring
                "startCallMonitoring" -> {
                    val success = startCallMonitoring()
                    result.success(success)
                }
                "stopCallMonitoring" -> {
                    stopCallMonitoring()
                    result.success(null)
                }

                // Audio Monitoring
                "startAudioMonitoring" -> {
                    val success = startAudioMonitoring()
                    result.success(success)
                }
                "stopAudioMonitoring" -> {
                    stopAudioMonitoring()
                    result.success(null)
                }

                // Notification Blocking
                "startNotificationBlocking" -> {
                    // Notification listener is controlled via system settings
                    val enabled = isNotificationListenerEnabled()
                    result.success(enabled)
                }
                "stopNotificationBlocking" -> {
                    result.success(null)
                }

                // Mute Control
                "muteCallAudio" -> {
                    val success = muteCall()
                    result.success(success)
                }
                "unmuteCallAudio" -> {
                    val success = unmuteCall()
                    result.success(success)
                }

                // End Call
                "endCall" -> {
                    val success = endCurrentCall()
                    result.success(success)
                }

                // Foreground Service
                "startForegroundService" -> {
                    val sessionId = call.argument<String>("sessionId") ?: ""
                    val durationMinutes = call.argument<Int>("durationMinutes") ?: 15
                    val success = startForegroundServiceCompat(sessionId, durationMinutes)
                    result.success(success)
                }
                "stopForegroundService" -> {
                    stopForegroundServiceCompat()
                    result.success(null)
                }

                // Permission Checks
                "isNotificationListenerEnabled" -> {
                    result.success(isNotificationListenerEnabled())
                }
                "openNotificationListenerSettings" -> {
                    openNotificationSettings()
                    result.success(null)
                }
                "canDrawOverlays" -> {
                    result.success(canDrawOverlays())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        // ── Event Channel (call state changes) ──────────────────
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onDestroy() {
        stopCallMonitoring()
        stopAudioMonitoring()
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        super.onDestroy()
    }

    // ────────────────────────────────────────────────────────────
    // Call Monitoring
    // ────────────────────────────────────────────────────────────

    private fun startCallMonitoring(): Boolean {
        if (isCallMonitoringActive) return true

        if (ActivityCompat.checkSelfPermission(
                this, Manifest.permission.READ_PHONE_STATE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return false
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                registerTelephonyCallbackS()
            } else {
                @Suppress("DEPRECATION")
                registerPhoneStateListener()
            }
            isCallMonitoringActive = true
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun registerTelephonyCallbackS() {
        val callback = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
            override fun onCallStateChanged(state: Int) {
                val stateStr = when (state) {
                    TelephonyManager.CALL_STATE_IDLE -> "IDLE"
                    TelephonyManager.CALL_STATE_RINGING -> "RINGING"
                    TelephonyManager.CALL_STATE_OFFHOOK -> "OFFHOOK"
                    else -> "UNKNOWN"
                }
                eventSink?.success(stateStr)
            }
        }
        telephonyManager?.registerTelephonyCallback(mainExecutor, callback)
        telephonyCallback = callback
    }

    @Suppress("DEPRECATION")
    private fun registerPhoneStateListener() {
        phoneStateListener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                val stateStr = when (state) {
                    TelephonyManager.CALL_STATE_IDLE -> "IDLE"
                    TelephonyManager.CALL_STATE_RINGING -> "RINGING"
                    TelephonyManager.CALL_STATE_OFFHOOK -> "OFFHOOK"
                    else -> "UNKNOWN"
                }
                eventSink?.success(stateStr)
            }
        }
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
    }

    private fun stopCallMonitoring() {
        if (!isCallMonitoringActive) return

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (telephonyCallback as? TelephonyCallback)?.let {
                    telephonyManager?.unregisterTelephonyCallback(it)
                }
                telephonyCallback = null
            } else {
                @Suppress("DEPRECATION")
                telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
                phoneStateListener = null
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        isCallMonitoringActive = false
    }

    // ────────────────────────────────────────────────────────────
    // Audio Monitoring (background recording for scam keyword detection)
    // ────────────────────────────────────────────────────────────

    private fun startAudioMonitoring(): Boolean {
        if (isAudioMonitoring) return true

        if (ActivityCompat.checkSelfPermission(
                this, Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return false
        }

        try {
            val sampleRate = 16000
            val channelConfig = AudioFormat.CHANNEL_IN_MONO
            val audioFormat = AudioFormat.ENCODING_PCM_16BIT
            val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)

            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_COMMUNICATION,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                audioRecord?.release()
                audioRecord = null
                return false
            }

            audioRecord?.startRecording()
            isAudioMonitoring = true

            // Read audio data in a background thread
            // In a real implementation, this would feed into a speech-to-text engine
            audioThread = Thread {
                val buffer = ShortArray(bufferSize)
                while (isAudioMonitoring) {
                    val readResult = audioRecord?.read(buffer, 0, buffer.size) ?: -1
                    if (readResult > 0) {
                        // TODO: Feed audio buffer to speech-to-text for scam keyword detection
                        // For now, this just captures audio to keep the mic active
                    }
                }
            }
            audioThread?.start()

            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun stopAudioMonitoring() {
        isAudioMonitoring = false
        try {
            audioThread?.join(1000)
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
            audioThread = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // ────────────────────────────────────────────────────────────
    // Mute Control
    // ────────────────────────────────────────────────────────────

    private fun muteCall(): Boolean {
        return try {
            audioManager?.isMicrophoneMute = true
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun unmuteCall(): Boolean {
        return try {
            audioManager?.isMicrophoneMute = false
            true
        } catch (e: Exception) {
            false
        }
    }

    // ────────────────────────────────────────────────────────────
    // End Call
    // ────────────────────────────────────────────────────────────

    private fun endCurrentCall(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                if (ActivityCompat.checkSelfPermission(
                        this, Manifest.permission.ANSWER_PHONE_CALLS
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    telecomManager.endCall()
                } else {
                    false
                }
            } else {
                // For older APIs, use ITelephony via reflection (best effort)
                @Suppress("DEPRECATION")
                val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                val method = tm.javaClass.getDeclaredMethod("endCall")
                method.invoke(tm) as? Boolean ?: false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    // ────────────────────────────────────────────────────────────
    // Foreground Service
    // ────────────────────────────────────────────────────────────

    private fun startForegroundServiceCompat(sessionId: String, durationMinutes: Int): Boolean {
        return try {
            val intent = Intent(this, SafeCallForegroundService::class.java).apply {
                putExtra("sessionId", sessionId)
                putExtra("durationMinutes", durationMinutes)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun stopForegroundServiceCompat() {
        try {
            stopService(Intent(this, SafeCallForegroundService::class.java))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // ────────────────────────────────────────────────────────────
    // Permission Helpers
    // ────────────────────────────────────────────────────────────

    private fun isNotificationListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat?.contains(packageName) == true
    }

    private fun openNotificationSettings() {
        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
    }

    private fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }

    // ────────────────────────────────────────────────────────────
    // Notification Channel
    // ────────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "SafeCall Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows when Stranger Mode is active"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
