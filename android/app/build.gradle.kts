plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // nach Android/Kotlin
    id("com.google.gms.google-services")    // ohne Version (Version ist im Root)
}

android {
    namespace = "com.example.studyproject"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.studyproject"
        minSdk = flutter.minSdkVersion                              // <<< Fix: Firestore braucht mind. 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true                   // optional, schadet nicht
    }

    // Java/Kotlin 17 (nutzt die JVM aus gradle.properties)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.multidex:multidex:2.0.1") // nur aktiv, wenn multiDexEnabled=true
}
