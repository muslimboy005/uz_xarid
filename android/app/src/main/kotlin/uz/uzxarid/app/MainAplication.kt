package uz.uzxarid.app

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setLocale("uz_UZ") // O'zbek tili uchun
        MapKitFactory.setApiKey("889ef8e3-0cfb-4dfb-8250-58a2f9f64db3") // Yandex API key
    }
}