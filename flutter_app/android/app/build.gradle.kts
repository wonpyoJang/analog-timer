plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dev.analogtimer.analog_timer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications(예약 알림) 가 core library desugaring 요구.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.analogtimer.analog_timer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // ML Kit OCR 가 다른 언어 인식기를 정적 참조 → R8 미포함 클래스 규칙 필요.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // flutter_local_notifications 예약 알림용 core library desugaring 런타임.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // 운동 TTS 워치 미러 — Data Layer 통신(폰→워치 상태, 워치→폰 명령)
    implementation("com.google.android.gms:play-services-wearable:18.1.0")
    // 봉지 OCR 한국어 인식기 — 플러그인이 compileOnly 로만 선언하므로(APK 미포함)
    // 앱이 런타임 의존성을 직접 추가해야 KoreanTextRecognizerOptions 클래스가 번들된다.
    implementation("com.google.mlkit:text-recognition-korean:16.0.1")
}
