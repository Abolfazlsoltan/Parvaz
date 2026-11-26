# Neon Survivor — Godot Android

نسخهٔ **Godot 4.4.1** بازی Neon Survivor با GDScript. ساخت APK امضاشده از طریق GitHub Actions انجام می‌شود.

## اجرای بازی
- با کشیدن انگشت، بازیکن را حرکت دهید.
- دابل‌تپ یا انگشت دوم برای **Dash**.
- شلیک به نزدیک‌ترین دشمن به‌صورت خودکار انجام می‌شود.
- تقویت‌کننده‌ها: Shield، Overdrive، Morph، Repair، Nuke، Magnet، Slow
- لمس صفحه برای شروع / شروع دوباره
- کلید P یا Escape برای توقف

## ساخت APK (Release امضاشده)
1. وارد زبانهٔ **Actions** شوید.
2. Workflow با نام **Build Neon Survivor Android APK** را انتخاب کنید.
3. پس از Push به `main` یا با **Run workflow** اجرا کنید.
4. Artifact به نام `NeonSurvivor-Android-APK` را دانلود کنید.

APK با **keystore دائمی** امضا می‌شود و برای به‌روزرسانی در Google Play قابل استفاده است.

## آیکون برنامه
آیکون سفارشی (جت جنگنده دایره‌ای) در CI از `godot/icons/source.jpg.b64` ساخته می‌شود و به عنوان launcher icon و adaptive icon تنظیم شده است.

## ساختار
- `godot/project.godot` — تنظیمات پروژه (نسخه ۱.۱.۱)
- `godot/main.tscn` — صحنه اصلی
- `godot/scripts/main.gd` — منطق بازی
- `godot/scripts/sound_bank.gd` — صدای رویه‌ای
- `godot/export_presets.cfg` — خروجی Android + امضای release
- `godot/android/SIGNING.md` — جزئیات keystore
- `godot/icons/source.jpg.b64` — منبع آیکون
- `.github/workflows/android.yml` — ساخت APK امضاشده

## انتشار در Google Play
- Package ID: `com.abolfazl.neonsurvivor`
- Version name: `1.1.1` / Version code: `4`
- Keystore alias: `neonsurvivor` (جزئیات در `godot/android/SIGNING.md`)
- برای آپلود نهایی معمولاً AAB لازم است؛ این CI فعلاً APK امضاشده می‌سازد (مناسب تست و sideload). برای AAB می‌توان Gradle build را بعداً فعال کرد.
- آیکون 1024px و اطلاعات Store listing را در Play Console تکمیل کنید.

**نکته امنیتی:** رمز keystore در workflow به‌صورت fallback وجود دارد. بهتر است آن‌ها را به GitHub Secrets منتقل کنید:
`ANDROID_KEYSTORE_PASSWORD`، `ANDROID_KEY_PASSWORD`، `ANDROID_KEY_ALIAS`
