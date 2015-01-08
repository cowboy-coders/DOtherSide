import NimQml
import macros
import typeinfo

proc mainProc() =
  let app = createQApplication()
  defer: app.delete()
   
  let engine = createQQmlApplicationEngine()
  defer: engine.delete()

  engine.load("main.qml")
  app.exec()

when isMainModule:
  mainProc()

