import NimQml
import Contact

proc mainProc() =
  let app = createQApplication()
  defer: app.delete()
   
  let contact = newContact()
  
  let engine = createQQmlApplicationEngine()
  defer: engine.delete()

  let variant = newQVariant(contact)

  let rootContext: QQmlContext = engine.rootContext()
  rootContext.setContextProperty("contact", variant)
  engine.load("main.qml")
  app.exec()

when isMainModule:
  mainProc()

