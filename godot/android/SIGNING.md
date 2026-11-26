# Neon Survivor — Android signing

## Release keystore (permanent)

| Field | Value |
|-------|--------|
| File | `neonsurvivor-release.keystore` (decoded from `.b64` in CI) |
| Alias | `neonsurvivor` |
| Store password | `NeonSurvivor2026!` |
| Key password | `NeonSurvivor2026!` |
| Validity | ~10000 days (until 2054) |

**Keep this keystore forever.** Google Play requires the same signing key for every update of the same package (`com.abolfazl.neonsurvivor`).

### Recommended: move passwords to GitHub Secrets

In the repo → Settings → Secrets and variables → Actions, add:

- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS` (optional, default `neonsurvivor`)

The workflow uses these secrets when present; otherwise it falls back to the values above.

### Package identity

- Application ID: `com.abolfazl.neonsurvivor`
- Version name: `1.1.0`
- Version code: `3` (must increase for every Play upload)

### Play Console notes

- New apps generally need an **AAB** (Android App Bundle). This CI produces a **signed release APK**, which is fine for sideloading and testing. For production Play upload, export AAB from Godot with Gradle enabled, or extend the workflow later.
- Use the high-res circular jet icon for the store listing (512–1024 px).
- Complete Store listing, content rating, and target audience forms before review.
