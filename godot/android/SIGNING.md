# Android signing

The current CI workflow produces a debug-signed APK for sideload testing. It does not use a persistent release keystore.

## Previous key exposure

A previous release keystore and signing credentials were committed to this public repository's Git history. Treat that key as compromised. Do not use it for a new Google Play or production release. Removing files from the current branch does not erase historical commits.

## Production release signing

Before creating a production release:
1. Generate a new release keystore on a trusted local machine.
2. Store the keystore and its credentials as protected GitHub Actions secrets.
3. Read those secrets only at build time from a dedicated release workflow.
4. Keep all private signing material out of the repository and build logs.

The development workflow intentionally uses a temporary Android debug key until a new protected release key is configured.
