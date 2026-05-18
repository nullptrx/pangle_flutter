plugins {
  id("com.android.library")
  id("org.jetbrains.kotlin.android")
}

group = "io.github.nullptrx.pangleflutter"
version = "3.0.0"

rootProject.allprojects {
  repositories {
    google()
    mavenCentral()
    maven { url = uri("https://artifact.bytedance.com/repository/pangle") }
  }
}

kotlin {
  jvmToolchain(17) // or appropriate version
  compilerOptions {
    freeCompilerArgs.add("-Xcontext-parameters")
  }
}

android {
  namespace = "io.github.nullptrx.pangleflutter"
  compileSdk = 36
  sourceSets {
    getByName("main") {
      java.srcDirs("src/main/kotlin")
    }
  }
  defaultConfig {
    minSdk = 24
  }
  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
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

dependencies {
  api("com.pangle.cn:ads-sdk-pro:[7.0,8.0)")
  implementation("androidx.appcompat:appcompat:[1.7,1.8)")
}
