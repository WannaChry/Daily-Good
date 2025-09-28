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
        minSdk = 23 // <<< Wichtig: wegen cloud_firestore von 21 auf 23 erhöht
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
}
