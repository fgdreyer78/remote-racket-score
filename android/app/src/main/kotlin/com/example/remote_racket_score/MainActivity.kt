package com.example.remote_racket_score

import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "com.remoteracketscore/volume"
    
    // A GRANDE SACADA: Já nasce com o buraco negro ligado, pois o app abre no Placar!
    private var isGameMode = true 
    
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

    // O BURACO NEGRO SIMÉTRICO E ABSOLUTO
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (isGameMode) {
            val keyCode = event.keyCode
            
            // TRATAMENTO EXATAMENTE IGUAL PARA UP E DOWN
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                
                if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                    if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
                        methodChannel?.invokeMethod("volumeUp", null)
                    } else if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                        methodChannel?.invokeMethod("volumeDown", null)
                    }
                }
                
                // Retorna true para blindar o sistema e esconder a barra
                return true 
            }
        }
        return super.dispatchKeyEvent(event)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (isGameMode && (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)) {
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent): Boolean {
        if (isGameMode && (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)) {
            return true
        }
        return super.onKeyUp(keyCode, event)
    }
}