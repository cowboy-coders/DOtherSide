import NimQml
import macros
import typeinfo

proc mainProc() =
  let app = createQApplication()
  defer: app.delete()
   
  let engine = createQQmlApplicationEngine()
  defer: engine.delete()

  let qVar1 = newQVariant(10)

  let qVar2 = newQVariant("Hello World")

  let qVar3 = newQVariant(false)
  
  engine.rootContext.setContextProperty("qVar1", qVar1) 
  engine.rootContext.setContextProperty("qVar2", qVar2)
  engine.rootContext.setContextProperty("qVar3", qVar3)
  
  engine.load("main.qml")
  app.exec()

when isMainModule:
  mainProc()

