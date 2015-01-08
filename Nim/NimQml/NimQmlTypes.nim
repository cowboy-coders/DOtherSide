import tables

type 
  RawQVariant* = distinct pointer 
    ## internal representation of a QVariant, as recognised by DOtherSide
  QQmlApplicationEngine* = distinct pointer ## A QQmlApplicationEngine
  QQmlContext* = distinct pointer ## A QQmlContext
  QApplication* = distinct pointer ## A QApplication
  RawQObject* = distinct pointer
    ## internal representation of a QObject
  QVariant* = ref object of RootObj
    ## A QVariant
    data*: RawQVariant
  QVariantNonGC* = ref object of QVariant
    ## Non-garbage collected QVariant
  QObjectObj* = object of RootObj ## A QObject
    name*: string
    data*: RawQObject
    slots*: Table[string, cint]
    signals*: Table[string, cint]
    properties*: Table[string, cint]
  QObject* = ref QObjectObj
  QQuickView* = distinct pointer ## A QQuickView
