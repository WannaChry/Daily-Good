// android/build.gradle.kts
import org.gradle.api.tasks.compile.JavaCompile

plugins {
    // Google Services Plugin hier versionieren (im :app ohne Version anwenden)
    id("com.google.gms.google-services") version "4.4.3" apply false
}

// Build-Ordner nach oben verlagern (optional)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")

    // >>> WARNUNGEN UNTERDRÜCKEN (javac)
    tasks.withType<JavaCompile>().configureEach {
        // unterdrückt "Quellwert/Zielwert 8 ist veraltet" & Deprecation-Hinweis
        options.compilerArgs.addAll(listOf("-Xlint:-options", "-Xlint:-deprecation"))
    }
    // <<<
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
