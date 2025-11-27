# shadow_mon_app

1. Change App Name (Display Name)
   This is the name users see on their phone screen under the app icon.

Open this file: android/app/src/main/AndroidManifest.xml

Find the android:label inside the <application> tag.

Change it to your desired name (e.g., "ShadowMon").
<application
android:label="ShadowMon" android:name="${applicationName}"
android:icon="@mipmap/ic_launcher">

2. Change Package Name (The "ID")
   The package name (e.g., com.example.shadowmon) must be unique if you upload to the Play Store. Changing this manually is difficult because you have to rename folders. Use this easy method:

Open your terminal in the project folder.

Run this command to add a helper tool (dev dependency):
flutter pub add change_app_package_name --dev

Run the command to change the name. (I used your name jakaria for this example):
flutter pub run change_app_package_name:main com.jakaria.shadowmon

3. Add Internet Permission
   Since your app uses an API (PokeAPI) and fetches images from the web, you must declare internet permission, or the release version will crash.

Open: android/app/src/main/AndroidManifest.xml

Paste the <uses-permission> line above the <application> tag.

<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="ShadowMon"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        ```

---

### 4. Build the App Bundle
Once you have saved the files above:

1.  **Clean the project** (to remove old cached names):
    ```bash
    flutter clean
    flutter pub get
    ```

2.  **Build the bundle**:
    ```bash
    flutter build appbundle
    ```

3.  **Locate the file**:
    Once finished, your file will be located at:
    `build/app/outputs/bundle/release/app-release.aab`

### Important Note for Play Store
If you plan to upload this `app-release.aab` to the Google Play Store, you will need to **Sign the App** using a Keystore file (creating a `.jks` file and adding it to `android/key.properties`).

If you just want to test it locally or send it to a friend, you might prefer building an APK instead:
`flutter build apk --split-per-abi`



A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
