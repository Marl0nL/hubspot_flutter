group = "io.github.marl0nl.hubspot_flutter_chat"
version = "1.0"

buildscript {
    val kotlinVersion = "2.3.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "io.github.marl0nl.hubspot_flutter_chat"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        // HubSpot's mobile chat SDK requires API 26+.
        minSdk = 26
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // HubSpot's official Android mobile chat SDK (package com.hubspot.mobilesdk).
    // Pinned to 1.0.7 to match the iOS SDK's latest release (HubSpot ships the
    // two platforms on independent cadences — Android is further ahead at
    // 1.0.9). Bump both platforms together when iOS catches up.
    implementation("com.hubspot.mobilechatsdk:mobile-chat-sdk-android:1.0.7")
    // setPushToken / logout are suspend functions; invoked from the plugin via
    // a coroutine scope.
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
}
