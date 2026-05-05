package uz.uzxarid.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey("889ef8e3-0cfb-4dfb-8250-58a2f9f64db3")
        super.configureFlutterEngine(flutterEngine)
        MapKitFactory.initialize(this)
    }
}
