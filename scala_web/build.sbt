
enablePlugins(ScalaJSPlugin)

name := "Scala.js Cycles Bench"
scalaVersion := "2.12.2"

// This is an application with a main method
scalaJSUseMainModuleInitializer := true



lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.symbolscope",
      scalaVersion := "2.12.4",
      version      := "0.1.0-SNAPSHOT"
    )),
    name := "cycles_sjs",
  )
