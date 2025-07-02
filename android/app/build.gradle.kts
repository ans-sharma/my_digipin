plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.anshuman.my_digipin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion // or "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.anshuman.my_digipin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

signingConfigs {
    create("release") {
        storeFile = file("key.jks")
        storePassword = project.properties["MY_KEYSTORE_PASSWORD"] as String
        keyAlias = project.properties["MY_KEY_ALIAS"] as String
        keyPassword = project.properties["MY_KEY_PASSWORD"] as String
    }
}

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
