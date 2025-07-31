package com.example.myhighst_map_app_v2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
//import com.example.myhighst_map_app_v2.BuildConfig

class MainActivity: FlutterActivity(){}

//{
//    private val CHANNEL = "com.example.myhighst_map_app_v2/secrets"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "getApiKey") {
//                val apiKey = BuildConfig.MAPS_API_KEY // Access the secret
//                result.success(apiKey)
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
//}
