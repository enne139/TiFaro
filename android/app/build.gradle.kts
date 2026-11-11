import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Dati della chiave di firma, letti da android/key.properties.
//
// Il file non sta nel repository: in locale lo crea chi pubblica, su GitHub lo
// scrive il flusso di rilascio a partire dai segreti. Se manca, la build di
// release usa la chiave di debug e l'APK resta installabile ma non
// aggiornabile (firma diversa su ogni macchina).
val proprietaFirma = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.enne139.tifaro"
    // receive_sharing_intent (tasto Condividi) si compila solo con le API 37.
    // Cambia solo con cosa si compila: targetSdk resta quello di Flutter.
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Gli avvisi programmati (flutter_local_notifications) usano le
        // date di Java 8 anche sui telefoni vecchi: servono le librerie
        // "desugared".
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.enne139.tifaro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // La configurazione esiste solo se la chiave c'è.
        if (proprietaFirma.isNotEmpty()) {
            create("release") {
                storeFile = file(proprietaFirma.getProperty("storeFile"))
                storePassword = proprietaFirma.getProperty("storePassword")
                keyAlias = proprietaFirma.getProperty("keyAlias")
                keyPassword = proprietaFirma.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
