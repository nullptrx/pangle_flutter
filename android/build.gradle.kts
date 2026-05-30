group = "io.github.nullptrx.pangleflutter"
version = "3.0.0"

plugins {
    id("com.android.library")
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifact.bytedance.com/repository/pangle") }
    }
}

android {
    namespace = "io.github.nullptrx.pangleflutter"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()
                it.outputs.upToDateWhen { false }
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }

    lint {
        disable += "InvalidPackage"
    }

    buildTypes {
        release {
            consumerProguardFiles("proguard-rules.pro")
        }
    }
}

pluginManager.withPlugin("org.jetbrains.kotlin.android") {
    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
            freeCompilerArgs.add("-Xcontext-parameters")
        }
    }
}

dependencies {
    api("com.pangle_beta.cn:mediation-sdk:[7.0,8.0)")
    implementation("androidx.appcompat:appcompat:[1.7,1.8)")
}
