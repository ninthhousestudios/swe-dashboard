# Android Release Signing Setup

## Step 1: Generate the upload keystore

Run this interactively — it will prompt for a password and identity info:

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Remember the password you set.

## Step 2: Create key.properties

Create `android/key.properties` with your password:

```properties
storePassword=YOUR_PASSWORD_HERE
keyPassword=YOUR_PASSWORD_HERE
keyAlias=upload
storeFile=app/upload-keystore.jks
```

## Step 3: Update build.gradle.kts

Replace the contents of `android/app/build.gradle.kts` with the version
shown below (the signing config reads from key.properties):

```kotlin
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystoreFile = rootProject.file("key.properties")
if (keystoreFile.exists()) {
    keystoreProperties.load(keystoreFile.inputStream())
}

android {
    namespace = "studio.ninthhouse.ephemeris_dashboard"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "studio.ninthhouse.ephemeris_dashboard"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
```

## Step 4: Add to .gitignore

```
android/key.properties
android/app/upload-keystore.jks
```

## Step 5: Build

```bash
# Play Store (required format):
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

# Sideload / GitHub:
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Important

- BACK UP `upload-keystore.jks` somewhere safe — lose it and you can never
  update the app on Play Store
- Never commit `key.properties` or `upload-keystore.jks`
- Play Store also requires: developer account ($25), screenshots, privacy
  policy, content rating questionnaire
