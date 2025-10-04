// En el archivo android/build.gradle.kts

buildscript {
    // Aquí definimos la versión de Kotlin para todo el proyecto Android.
    val kotlinVersion = "1.9.23"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // La versión de las herramientas de Gradle puede variar, la tuya puede ser diferente.
        classpath("com.android.tools.build:gradle:8.2.1") 
        // Esta línea es la importante, le dice que use el plugin de Kotlin.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}