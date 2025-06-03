plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin harus dipasang setelah plugin Android & Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.projek_prak_mobile"
    compileSdk = 35  // atau sesuaikan dengan flutter.compileSdkVersion kalau variabel flutter tersedia

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.projek_prak_mobile"
        minSdk = 21  // sesuaikan dengan kebutuhan minimal SDK aplikasi
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        isCoreLibraryDesugaringEnabled = true  // harus huruf besar 'C' di Core
    }

    kotlinOptions {
        jvmTarget = "11"  // harus string, bukan JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.9.0") // opsional, tapi umum
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // wajib untuk desugaring
}

flutter {
    source = "../.."
}
