# Google Sign-In SHA-1 Fingerprint Fix

## Issue
Your current SHA-1 fingerprint (`39:E9:98:00:56:AE:21:BA:E9:22:A2:1F:94:8B:8E:5A:D1:98:1C:0B`) doesn't match the one in your google-services.json file (`40d7fc520b501a328986fd1798f2d98e9f8925cd`).

## Solution Steps

### Option 1: Update Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project "Kalpvraksha"
3. Go to Project Settings (gear icon)
4. Navigate to "Your apps" section
5. Find your Android app
6. In the SHA certificate fingerprints section, add:
   ```
   SHA1: 39:E9:98:00:56:AE:21:BA:E9:22:A2:1F:94:8B:8E:5A:D1:98:1C:0B
   ```
7. Download the new google-services.json file
8. Replace the existing one in your android/app/ directory

### Option 2: Generate New Keystore (For Production)
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Option 3: Use Existing Fingerprint
If you want to keep using the fingerprint from google-services.json:
```bash
# Generate new debug keystore with specific fingerprint (not recommended)
```

## Quick Test
After updating Firebase console, test the Google Sign-In:
```bash
flutter clean
flutter build apk --debug
```

## Verification
Run this command to verify your current fingerprint:
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
```

Your current fingerprint should be:
SHA1: 39:E9:98:00:56:AE:21:BA:E9:22:A2:1F:94:8B:8E:5A:D1:98:1C:0B
