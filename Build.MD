# OnMint Healthcare Platform - Complete Build Guide

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [API Configuration](#api-configuration)
3. [Build Steps for All Apps](#build-steps-for-all-apps)
4. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before building, ensure you have:

- ✅ Flutter SDK (>=3.16.0)
- ✅ Dart SDK (>=3.0.0)
- ✅ Android SDK / Xcode
- ✅ Git
- ✅ Backend API running or hosted

---

## 🔧 API Configuration

**IMPORTANT: Do this FIRST before building any app!**

### Step 1: Edit API Configuration File

Navigate to:
```
New_Onmint/shared_packages/api_client/lib/src/config/api_config.dart
```

### Step 2: Update Base URL

For **Local Development** (API running on localhost):
```dart
static const String _baseUrlDev = 'http://localhost:5000/api/v1';
static const bool _isProduction = false;
```

For **Hosted API** (When API is deployed):
```dart
static const String _baseUrlDev = 'https://your-api-domain.com/api/v1';
static const bool _isProduction = false;
```

For **Production Environment** (Separate prod server):
```dart
static const String _baseUrlDev = 'https://staging-api.com/api/v1';
static const String _baseUrlProd = 'https://production-api.com/api/v1';
static const bool _isProduction = true;  // Set to true for production builds
```

### Step 3: Save and Verify

After editing, the change applies to **all three apps automatically**:
- ✅ User App
- ✅ Vendor App
- ✅ Admin App

---

## 🚀 Build Steps for All Apps

### COMMON: Clean Flutter Cache (First Time Only)

```bash
flutter clean  // dont do flutter clean more than one time (only at first time --)
flutter pub get --upgrade
```

---

## 📱 App 1: User App

### Step 1: Navigate to User App
```bash
cd New_Onmint/user_app
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Upgrade Dependencies (Optional)
```bash
flutter pub upgrade
```

### Step 4: Build APK (Debug)
```bash
flutter build apk --debug --verbose
```

**Output location:**
```
New_Onmint/user_app/build/app/outputs/flutter-apk/app-debug.apk
```


**Output location:**
```
New_Onmint/user_app/build/web/
```

---

## 🏥 App 2: Vendor App

### Step 1: Navigate to Vendor App
```bash
cd New_Onmint/vendor_app
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Upgrade Dependencies (Optional)
```bash
flutter pub upgrade
```

### Step 4: Build APK (Debug)
```bash
flutter build apk --debug --verbose
```

**Output location:**
```
New_Onmint/vendor_app/build/app/outputs/flutter-apk/app-debug.apk
```


**Output location:**
```
New_Onmint/vendor_app/build/web/
```

---

## 👨‍💼 App 3: Admin App

### Step 1: Navigate to Admin App
```bash
cd New_Onmint/admin_app
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Upgrade Dependencies (Optional)
```bash
flutter pub upgrade
```

### Step 4: Build APK (Debug)
```bash
flutter build apk --debug --verbose
```

**Output location:**
```
New_Onmint/admin_app/build/app/outputs/flutter-apk/app-debug.apk
```



**Output location:**
```
New_Onmint/admin_app/build/web/
```

---

## 🎯 Quick Build All Apps (Batch)

### For Windows (PowerShell):

```powershell
# User App
cd New_Onmint/user_app
flutter clean
flutter pub get
flutter build apk --debug --verbose

# Vendor App
cd ../vendor_app
flutter clean
flutter pub get
flutter build apk --debug --verbose

# Admin App
cd ../admin_app
flutter clean
flutter pub get
flutter build apk --debug --verbose

# Go back to root
cd ../..
```

### For Mac/Linux (Bash):

```bash
#!/bin/bash

# User App
cd New_Onmint/user_app
flutter clean && flutter pub get && flutter build apk --debug --verbose

# Vendor App
cd ../vendor_app
flutter clean && flutter pub get && flutter build apk --debug --verbose

# Admin App
cd ../admin_app
flutter clean && flutter pub get && flutter build apk --debug --verbose

# Go back to root
cd ../..

echo "✅ All apps built successfully!"
```

---

## 📦 Build Modes Explained

### Debug Build (Recommended for Development)
```bash
flutter build apk --debug --verbose
```
- Includes debugging symbols
- Larger file size
- Faster build time
- Good for testing

### Release Build (For Production)
```bash
flutter build apk --release --verbose
```
- Optimized code
- Smaller file size
- Slower build time
- Use for app store submission

### Profile Build (For Performance Testing)
```bash
flutter build apk --profile --verbose
```
- Profiling enabled
- Optimized code
- Good for performance analysis

---

## 📊 Build Output Locations

```
New_Onmint/
├── user_app/
│   └── build/app/outputs/flutter-apk/
│       └── app-debug.apk
├── vendor_app/
│   └── build/app/outputs/flutter-apk/
│       └── app-debug.apk
└── admin_app/
    └── build/app/outputs/flutter-apk/
        └── app-debug.apk
```

---

## 🧹 Troubleshooting

### Issue: Gradle sync failed

**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Issue: Dependencies not found

**Solution:**
```bash
flutter pub cache clean
flutter pub get
```

### Issue: Build fails with version mismatch

**Solution:**
```bash
flutter upgrade
flutter pub upgrade
```

### Issue: "cannot find -lc++"

**Solution:**
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### Issue: API endpoints not working

**Solution:**
1. Verify API configuration in `api_config.dart`
2. Ensure backend is running
3. Check network connectivity
4. Verify domain/localhost is correct

### Issue: Build takes too long

**Solution:**
- Use `flutter build apk --debug` (faster)
- Skip verbose output if not needed
- Close other applications

---

## ✅ Verification Checklist

Before distributing APKs:

- [ ] API configuration updated (`api_config.dart`)
- [ ] All three apps build successfully
- [ ] No errors in build logs
- [ ] APK files generated in output locations
- [ ] Test on device/emulator works
- [ ] Network requests work correctly
- [ ] All features functional

---

## 🚀 Deployment Steps

### Step 1: Build Release APKs
```bash
# For each app:
cd New_Onmint/{app_name}
flutter build apk --release --verbose
```

### Step 2: Generate Release Signatures (Optional)
```bash
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore your_keystore.jks \
  app-release.apk your_alias
```

### Step 3: Align APK (Optional)
```bash
zipalign -v 4 app-release.apk app-release-aligned.apk
```

### Step 4: Upload to Store

**Google Play Store:**
- Use Google Play Console
- Upload signed APK
- Add metadata and screenshots
- Submit for review

---

## 📝 Summary

### Quick Checklist for Each App:

1. **Update API Config** (do once for all apps)
   - Edit `api_config.dart`
   - Set correct base URL
   - Set `_isProduction` flag

2. **Navigate to app directory**
   ```bash
   cd New_Onmint/{user_app|vendor_app|admin_app}
   ```

3. **Get dependencies**
   ```bash
   flutter pub get
   ```

4. **Optional: Upgrade**
   ```bash
   flutter pub upgrade
   ```

5. **Build APK**
   ```bash
   flutter build apk --debug --verbose
   ```

6. **Find APK**
   ```
   build/app/outputs/flutter-apk/app-debug.apk
   ```

---

## 🔗 Related Documentation

- **API Configuration:** `API_CONFIG_SETUP_GUIDE.md`
- **Architecture:** `docs/en/ARCHITECTURE.md`
- **Contributing:** `CONTRIBUTING.md`

---

## 📞 Support

For issues:
1. Check troubleshooting section
2. Run `flutter doctor` to diagnose environment
3. Check build logs for specific errors
4. Verify API endpoint configuration

---

**Last Updated:** June 17, 2026  
**Status:** ✅ Ready for Production  
**Version:** 1.0
