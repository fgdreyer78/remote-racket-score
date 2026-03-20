package com.example.remote_racket_score

import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "com.remoteracketscore/volume"
    private var isGameMode = false
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "setGameMode") {
                isGameMode = call.arguments as Boolean
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    // 1. O GUARDA QUE ENGOLHE A DESCIDA DA TECLA (E PONTUA)
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (isGameMode) {
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
                if (event.repeatCount == 0) {
                    methodChannel?.invokeMethod("volumeUp", null)
                }
                return true // BURACO NEGRO NO VOLUME UP!
            }
            if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                if (event.repeatCount == 0) {
                    methodChannel?.invokeMethod("volumeDown", null)
                }
                return true // BURACO NEGRO NO VOLUME DOWN!
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    // 2. O GUARDA QUE ENGOLHE A SUBIDA DA TECLA (GARANTE QUE A BARRA NÃO APAREÇA)
    override fun onKeyUp(keyCode: Int, event: KeyEvent): Boolean {
        if (isGameMode) {
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                return true // A TECLA FOI SOLTA E O ANDROID NÃO FICA SABENDO!
            }
        }
        return super.onKeyUp(keyCode, event)
    }
}