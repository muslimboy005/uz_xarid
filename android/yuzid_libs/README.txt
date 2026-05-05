YuzID Android: detection-0.0.3.aar
================================

MUHIM
-----
1) https://api.yuzid.uz/auth/get-token  — bu REST API JWT uchun (ilovada Dio orqali).
   Nexus Maven artefaktlari uchun JWT ISHLATILMAYDI.

2) Gradle / curl bilan Nexus ga kirishda ko‘pincha 403 chiqadi, chunki
   nexus.yt.uz Cloudflare himoyasida — brauzerdan tashqari so‘rovlar bloklanadi.
   Shuning uchun login/parol (uzxarid / …) bo‘lsa ham Gradle ba’zan yuklay olmaydi.

Yechim (APK yig‘ish uchun)
--------------------------
`detection-0.0.3.aar` faylini shu papkaga qo‘ying:

  android/yuzid_libs/detection-0.0.3.aar

Fayl bor bo‘lsa, loyiha Nexus ga umuman murojaat qilmaydi va build ishlashi kerak.

Qayerdan olish
--------------
• YuzID / SoliqID qo‘llab-quvvatlashidan to‘g‘ridan-to‘g‘ri so‘rang.
• Yoki Nexus ochiladigan ofis / VPN dagi kompyuterdan brauzer orqali yuklab oling.
• Yoki muvaffaqiyatli yig‘ilgan mashinadan Gradle keshidan nusxa:

  ~/.gradle/caches/modules-2/files-2.1/uz.face.detection/detection/0.0.3/

Gradle keshida papka nomi hash bilan; ichida .aar bo‘ladi.
