# Neon Survivor — Godot Android

نسخهٔ اصلی پروژه با **Godot 4.4.1 و GDScript** ساخته می‌شود. ساخت APK از طریق GitHub Actions انجام می‌شود.

## اجرای بازی
- با کشیدن انگشت در نیمهٔ چپ صفحه، بازیکن را حرکت دهید.
- با لمس سمت راست صفحه، Dash اجرا کنید.
- شلیک به نزدیک‌ترین دشمن به‌صورت خودکار انجام می‌شود.
- سه تقویت‌کنندهٔ Shield، Triple Shot و Nova در بازی وجود دارند.
- برای شروع یا شروع دوباره، صفحه را لمس کنید.
- با کلید P یا Escape بازی را متوقف/ادامه دهید.

## ساخت APK
1. وارد زبانهٔ **Actions** مخزن شوید.
2. Workflow با نام **Build Neon Survivor Android APK** را انتخاب کنید.
3. اجرای خودکار پس از Push به شاخهٔ `main` انجام می‌شود؛ یا از گزینهٔ **Run workflow** استفاده کنید.
4. پس از موفقیت، فایل `NeonSurvivor-Android-APK` را از بخش Artifacts همان اجرا دریافت کنید.

## ساختار پروژه
- `godot/project.godot`: تنظیمات پروژه
- `godot/main.tscn`: صحنهٔ اصلی
- `godot/scripts/main.gd`: منطق بازی، کنترل لمسی، دشمن‌ها، تیراندازی، امتیاز و رابط بصری
- `godot/export_presets.cfg`: تنظیمات خروجی Android
- `.github/workflows/android.yml`: ساخت و انتشار Artifact فایل APK

این Workflow یک APK آزمایشیِ امضاشده با کلید موقت CI می‌سازد؛ برای انتشار در فروشگاه باید کلید انتشار اختصاصی و امن تنظیم شود.
