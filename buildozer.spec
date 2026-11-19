[app]
title = Neon Survivor
package.name = neonsurvivor
package.domain = com.abolfazl.parvaz
source.dir = .
source.include_exts = py,png,jpg,kv,json
version = 1.0.0
requirements = python3,kivy==2.3.2,charset-normalizer==2.1.1
orientation = landscape
fullscreen = 1
android.api = 36
android.minapi = 24
android.ndk = 29
android.archs = arm64-v8a
android.accept_sdk_license = True
android.release_artifact = aab
p4a.bootstrap = sdl2
p4a.branch = develop
[buildozer]
log_level = 2
warn_on_root = 1
