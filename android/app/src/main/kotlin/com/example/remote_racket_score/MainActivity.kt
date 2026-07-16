package com.example.remote_racket_score

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.remoteracketscore/volume"
    private var gameMode = false
    private var volumeChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        volumeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        volumeChannel?.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            if (call.method == "setGameMode") {
                gameMode = call.arguments() as? Boolean ?: false
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN && gameMode) {
            when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    volumeChannel?.invokeMethod("volumeUp", null)
                    return true
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    volumeChannel?.invokeMethod("volumeDown", null)
                    return true
                }
            }
        }
        return super.dispatchKeyEvent(event)
    }
}