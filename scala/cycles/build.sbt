import Dependencies._

mainClass in assembly := Some("cycles.Main")


lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.example",
      scalaVersion := "2.12.4",
      version      := "0.1.0-SNAPSHOT"
    )),
    name := "cycles",
    libraryDependencies += scalaTest % Test
  )
