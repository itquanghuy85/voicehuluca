package com.vietvoice.vietvoice_studio

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null
    private var settingsChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        settingsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SETTINGS_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "openAppSettings" -> {
                        val intent = Intent(
                            "android.settings.APPLICATION_DETAILS_SETTINGS",
                            Uri.parse("package:" + packageName),
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        try {
                            startActivity(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("open_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToPublicDownloads" -> {
                        val sourcePath = call.argument<String>("path")
                        val fileName = call.argument<String>("fileName")
                        if (sourcePath.isNullOrBlank() || fileName.isNullOrBlank()) {
                            result.error("bad_args", "path and fileName are required", null)
                        } else {
                            try {
                                result.success(copyToPublicDownloads(sourcePath, fileName))
                            } catch (e: Exception) {
                                result.error("save_failed", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
        channel = null
        settingsChannel?.setMethodCallHandler(null)
        settingsChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun mimeTypeOf(fileName: String): String = when {
        fileName.endsWith(".mp3", ignoreCase = true) -> "audio/mpeg"
        fileName.endsWith(".wav", ignoreCase = true) -> "audio/wav"
        fileName.endsWith(".m4a", ignoreCase = true) -> "audio/mp4"
        fileName.endsWith(".ogg", ignoreCase = true) -> "audio/ogg"
        fileName.endsWith(".aac", ignoreCase = true) -> "audio/aac"
        fileName.endsWith(".flac", ignoreCase = true) -> "audio/flac"
        fileName.endsWith(".txt", ignoreCase = true) -> "text/plain"
        fileName.endsWith(".json", ignoreCase = true) -> "application/json"
        else -> "application/octet-stream"
    }

    private fun copyToPublicDownloads(sourcePath: String, fileName: String): String {
        val source = File(sourcePath)
        if (!source.exists()) throw IllegalStateException("Source file not found")

        val mimeType = mimeTypeOf(fileName)
        val resolver = contentResolver

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS + "/" + ALBUM,
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("MediaStore rejected the insert")
            try {
                resolver.openOutputStream(uri)?.use { out ->
                    source.inputStream().use { input -> input.copyTo(out) }
                } ?: throw IllegalStateException("Cannot open output stream")
                val done = ContentValues().apply {
                    put(MediaStore.MediaColumns.IS_PENDING, 0)
                }
                resolver.update(uri, done, null, null)
                "Downloads/$ALBUM/$fileName"
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
        } else {
            @Suppress("DEPRECATION")
            val downloads = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS,
            )
            val albumDir = File(downloads, ALBUM)
            if (!albumDir.exists()) albumDir.mkdirs()
            val dest = File(albumDir, fileName)
            source.copyTo(dest, overwrite = true)
            dest.absolutePath
        }
    }

    companion object {
        private const val CHANNEL = "com.vietvoice.vietvoice_studio/storage"
        private const val SETTINGS_CHANNEL = "com.vietvoice.vietvoice_studio/settings"
        private const val ALBUM = "VietVoice"
    }
}