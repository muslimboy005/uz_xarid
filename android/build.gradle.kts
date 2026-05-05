import org.gradle.authentication.http.BasicAuthentication

val yuzFaceDetectionAar = rootProject.layout.projectDirectory.file("yuzid_libs/detection-0.0.3.aar").asFile

allprojects {
    repositories {
        google()
        mavenCentral()
        // AAR bor bo‘lsa Nexus kerak emas (Cloudflare Gradle ni ko‘pincha bloklaydi).
        if (!yuzFaceDetectionAar.exists()) {
            maven {
                url = uri("https://nexus.yt.uz/repository/maven-public/")
                credentials {
                    username =
                        rootProject.providers
                            .gradleProperty("YUZID_MAVEN_USER")
                            .orElse("uzxarid")
                            .get()
                    password =
                        rootProject.providers
                            .gradleProperty("YUZID_MAVEN_PASSWORD")
                            .orElse("an2t-E8j")
                            .get()
                }
                authentication {
                    create<BasicAuthentication>("basic")
                }
            }
        }
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
