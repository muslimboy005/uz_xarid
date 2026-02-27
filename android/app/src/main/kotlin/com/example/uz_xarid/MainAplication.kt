package com.example.uz_xarid

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setLocale("uz_UZ") // O'zbek tili uchun
        MapKitFactory.setApiKey("f1446954-e2bd-4242-882e-288e9b66e35c") // Yandex API key
    }
}