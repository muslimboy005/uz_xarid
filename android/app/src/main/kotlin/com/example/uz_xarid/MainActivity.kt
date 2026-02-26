package com.example.uz_xarid

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey("f1446954-e2bd-4242-882e-288e9b66e35c")
        super.configureFlutterEngine(flutterEngine)
        MapKitFactory.initialize(this)
    }
}
