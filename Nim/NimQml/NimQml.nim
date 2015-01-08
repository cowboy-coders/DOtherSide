
import NimQmlTypes
import tables
import typetraits

## NimQml aims to provide binding to the QML for the Nim programming language

export QObject
export QApplication
export QVariant
export QQmlApplicationEngine
export QQmlContext

type QMetaType* {.pure.} = enum ## \
  ## Qt metatypes values used for specifing the 
  ## signals and slots argument and return types.
  ##
  ## This enum mimic the QMetaType::Type C++ enum
  UnknownType = cint(0), 
  Bool = cint(1),
  Int = cint(2), 
  QString = cint(10), 
  VoidStar = cint(31),
  QVariant = cint(41), 
  Void = cint(43)

proc debugMsg(message: string) = 
  echo "NimQml: ", message

proc debugMsg(typeName: string, procName: string) = 
  var message = typeName
  message &= ": "
  message &= procName
  debugMsg(message)

proc debugMsg(typeName: string, procName: string, userMessage: string) = 
  var message = typeName
  message &= ": "
  message &= procName
  message &= " "
  message &= userMessage
  debugMsg(message)

# QVariant
proc dos_qvariant_create(variant: var RawQVariant) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_create_int(variant: var RawQVariant, value: cint) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_create_bool(variant: var RawQVariant, value: bool) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_create_string(variant: var RawQVariant, value: cstring) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_create_qobject(variant: var RawQVariant, value: RawQObject) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_delete(variant: RawQVariant) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_isnull(variant: RawQVariant, isNull: var bool) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_toInt(variant: RawQVariant, value: var cint) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_toBool(variant: RawQVariant, value: var bool) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_toString(variant: RawQVariant, value: var cstring, length: var cint) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_setInt(variant: RawQVariant, value: cint) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_setBool(variant: RawQVariant, value: bool) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qvariant_setString(variant: RawQVariant, value: cstring) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_chararray_delete(rawCString: cstring) {.cdecl, dynlib:"libDOtherSide.so", importc.}

proc nilKeepAliveRefs(variant: QVariant) =
  variant.variant = nil
  variant.qobject = nil

proc create*(variant: var QVariant) =
  ## Create a new QVariant
  dos_qvariant_create(variant.data)

proc create*(variant: var QVariant, value: cint) = 
  ## Create a new QVariant given a cint value
  dos_qvariant_create_int(variant.data, value)

proc create*(variant: var QVariant, value: bool) =
  ## Create a new QVariant given a bool value  
  dos_qvariant_create_bool(variant.data, value)

proc create*(variant: var QVariant, value: string) = 
  ## Create a new QVariant given a string value
  variant.variant = variant
  dos_qvariant_create_string(variant.data, value)

proc create*(variant: var QVariant, value: QObject) =
  ## Create a new QVariant given a QObject
  variant.qobject = value
  dos_qvariant_create_qobject(variant.data, value.data)

proc delete*(variant: QVariant) = 
  ## Delete a QVariant
  debugMsg("QVariant", "delete")
  dos_qvariant_delete(variant.data)

proc isNull*(variant: QVariant): bool = 
  ## Return true if the QVariant value is null, false otherwise
  dos_qvariant_isnull(variant.data, result)

proc intVal*(variant: QVariant): int = 
  ## Return the QVariant value as int
  var rawValue: cint
  dos_qvariant_toInt(variant.data, rawValue)
  result = rawValue.cint

proc `intVal=`*(variant: QVariant, value: int) = 
  ## Sets the QVariant value int value
  nilKeepAliveRefs(variant)
  var rawValue = value.cint
  dos_qvariant_setInt(variant.data, rawValue)

proc boolVal*(variant: QVariant): bool = 
  ## Return the QVariant value as bool
  dos_qvariant_toBool(variant.data, result)

proc `boolVal=`*(variant: QVariant, value: bool) =
  ## Sets the QVariant bool value
  nilKeepAliveRefs(variant)
  dos_qvariant_setBool(variant.data, value)

proc stringVal*(variant: QVariant): string = 
  ## Return the QVariant value as string
  var rawCString: cstring
  var rawCStringLength: cint
  dos_qvariant_toString(variant.data, rawCString, rawCStringLength)
  result = $rawCString
  dos_chararray_delete(rawCString)

proc `stringVal=`*(variant: QVariant, value: string) = 
  ## Sets the QVariant string value
  nilKeepAliveRefs(variant)
  dos_qvariant_setString(variant.data, value)

proc finalizeQVariant(variant: QVariant) =
  delete(variant)

proc newQVariant*(stringVal: string): QVariant =
  ## Create a new QVariant given a string value
  new(result, finalizeQVariant)
  result.create(stringVal)

proc newQVariant*(boolVal: bool): QVariant =
  ## Create a new QVariant given a bool value
  new(result, finalizeQVariant)
  result.create(boolVal)

proc newQVariant*(intVal: int): QVariant =
  ## Create a new QVariant given a cint value
  new(result, finalizeQVariant)
  result.create(intval.cint)

proc newQVariant*(qobject: QObject): QVariant =
  ## Create a new QVariant given a QObject
  new(result, finalizeQVariant)
  result.create(qobject)

proc newQVariant(raw: RawQVariant): QVariant =
  ## wrap a ``RawQVariant`` with a finalizer
  new(result, finalizeQVariant)
  result.data = raw

proc createQVariant*(raw: RawQVariant): QVariantNonGC =
  ## wrap a `RawQVariant`` without a finalizer
  new(result)
  result.data = raw

# QQmlApplicationEngine
proc dos_qqmlapplicationengine_create(engine: var QQmlApplicationEngine) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qqmlapplicationengine_load(engine: QQmlApplicationEngine, filename: cstring) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qqmlapplicationengine_context(engine: QQmlApplicationEngine, context: var QQmlContext) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qqmlapplicationengine_delete(engine: QQmlApplicationEngine) {.cdecl, dynlib:"libDOtherSide.so", importc.}

proc create*(engine: var QQmlApplicationEngine) = 
  ## Create an new QQmlApplicationEngine
  dos_qqmlapplicationengine_create(engine)

proc load*(engine: QQmlApplicationEngine, filename: cstring) = 
  ## Load the given Qml file 
  dos_qqmlapplicationengine_load(engine, filename)

proc rootContext*(engine: QQmlApplicationEngine): QQmlContext =
  ## Return the engine root context
  dos_qqmlapplicationengine_context(engine, result)

proc delete*(engine: QQmlApplicationEngine) = 
  ## Delete the given QQmlApplicationEngine
  debugMsg("QQmlApplicationEngine", "delete")
  dos_qqmlapplicationengine_delete(engine)

proc createQQmlApplicationEngine*(): QQmlApplicationEngine =
  ## Create an new QQmlApplicationEngine
  result.create

# QQmlContext
proc dos_qqmlcontext_setcontextproperty(context: QQmlContext, propertyName: cstring, propertyValue: RawQVariant) {.cdecl, dynlib:"libDOtherSide.so", importc.}

proc setContextProperty*(context: QQmlContext, propertyName: string, propertyValue: QVariant) = 
  ## Sets a new property with the given value
  dos_qqmlcontext_setcontextproperty(context, propertyName, propertyValue.data)

# QApplication
proc dos_qguiapplication_create() {.cdecl, dynlib: "libDOtherSide.so", importc.}
proc dos_qguiapplication_exec() {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qguiapplication_delete() {.cdecl, dynlib:"libDOtherSide.so", importc.}

proc create*(application: QApplication) = 
  ## Create a new QApplication
  dos_qguiapplication_create()

proc exec*(application: QApplication) =
  ## Start the Qt event loop
  dos_qguiapplication_exec()

proc delete*(application: QApplication) = 
  ## Delete the given QApplication
  dos_qguiapplication_delete()

proc createQApplication*(): QApplication =
  ## Create a new QApplication
  result.create

# QObject
type QVariantArray {.unchecked.} = array[0..0, RawQVariant]
type QVariantArrayPtr = ptr QVariantArray

proc toVariantSeq(args: QVariantArrayPtr, numArgs: cint): seq[QVariant] =
  result = @[]
  for i in 0..numArgs-1:
    let variant = createQVariant(args[i])
    result.add(variant)

proc toCIntSeq(metaTypes: openarray[QMetaType]): seq[cint] =
  result = @[]
  for metaType in metaTypes:
    result.add(cint(metaType))

proc toRawSeq(wrapped: openarray[QVariant]): seq[RawQVariant] =
  result = @[]
  for variant in wrapped:
    result.add variant.data

type QObjectCallBack = proc(nimobject: ptr QObjectObj, slotName: RawQVariant, numArguments: cint, arguments: QVariantArrayPtr) {.cdecl.}
    
proc dos_qobject_create(qobject: var RawQObject, nimobject: ptr QObjectObj, qobjectCallback: QObjectCallBack) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qobject_delete(qobject: RawQObject) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qobject_slot_create(qobject: RawQObject, slotName: cstring, argumentsCount: cint, argumentsMetaTypes: ptr cint, slotIndex: var cint) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qobject_signal_create(qobject: RawQObject, signalName: cstring, argumentsCount: cint, argumentsMetaTypes: ptr cint, signalIndex: var cint) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qobject_signal_emit(qobject: RawQObject, signalName: cstring, argumentsCount: cint, arguments: ptr RawQVariant) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qobject_property_create(qobject: RawQObject, propertyName: cstring, propertyType: cint, readSlot: cstring, writeSlot: cstring, notifySignal: cstring) {.cdecl, dynlib:"libDOtherSide.so", importc.}

method onSlotCalled*(nimobject: QObject, slotName: string, args: openarray[QVariant]) =
  ## Called from the NimQml bridge when a slot is called from Qml.
  ## Subclasses can override the given method for handling the slot call
  discard

proc qobjectCallback(nimobject: ptr QObjectObj, slotName: RawQVariant, numArguments: cint, arguments: QVariantArrayPtr) {.cdecl, exportc.} =
  let qobject = cast[QObject](nimobject) #FIXME: is this safe?!
  assert qobject != nil, "expecting valid QObject"
  let variant = createQVariant(slotName)
  # forward to the QObject subtype instance
  qobject.onSlotCalled(variant.stringVal, arguments.toVariantSeq(numArguments))

proc create*(qobject: QObject) =
  ## Create a new QObject
  let qobjectPtr = addr(qobject[])
  qobject.name = "QObject"
  qobject.slots = initTable[string,cint]()
  qobject.signals = initTable[string, cint]()
  dos_qobject_create(qobject.data, qobjectPtr, qobjectCallback)

proc delete*(qobject: QObject) = 
  ## Delete the given QObject
  debugMsg("QObject", "delete " & qobject.name)
  dos_qobject_delete(qobject.data)

proc finalizeQObject[T:QObject](qobject: T) =
  delete(qobject)

proc newQObject*[T:QObject](qobject: var T) =
  new(qobject,finalizeQObject[T])
  create(qobject)
  qobject.name = T.name

proc registerSlot*(qobject: QObject,
                   slotName: string, 
                   metaTypes: openarray[QMetaType]) =
  ## Register a slot in the QObject with the given name and signature
  # Copy the metatypes array
  var copy = toCIntSeq(metatypes)
  var index: cint 
  dos_qobject_slot_create(qobject.data, slotName, cint(copy.len), addr(copy[0].cint), index)
  qobject.slots[slotName] = index

proc registerSignal*(qobject: QObject,
                     signalName: string, 
                     metatypes: openarray[QMetaType]) =
  ## Register a signal in the QObject with the given name and signature
  var index: cint 
  if metatypes.len > 0:
    var copy = toCIntSeq(metatypes)
    dos_qobject_signal_create(qobject.data, signalName, copy.len.cint, addr(copy[0].cint), index)
  else:
    dos_qobject_signal_create(qobject.data, signalName, 0, nil, index)
  qobject.signals[signalName] = index

proc registerProperty*(qobject: QObject,
                       propertyName: string, 
                       propertyType: QMetaType, 
                       readSlot: string, 
                       writeSlot: string, 
                       notifySignal: string) =
  ## Register a property in the QObject with the given name and type.
  dos_qobject_property_create(qobject.data, propertyName, propertyType.cint, readSlot, writeSlot, notifySignal)

proc emit*(qobject: QObject, signalName: string, args: openarray[QVariant] = []) =
  ## Emit the signal with the given name and values
  if args.len > 0: 
    var argsAsRaw = toRawSeq(args)
    dos_qobject_signal_emit(qobject.data, signalName, args.len.cint, addr(argsAsRaw[0]))
  else:
    dos_qobject_signal_emit(qobject.data, signalName, 0, nil)

# QQuickView
proc dos_qquickview_create(view: var QQuickView) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qquickview_delete(view: QQuickView) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qquickview_show(view: QQuickView) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qquickview_source(view: QQuickView, filename: var cstring, length: var int) {.cdecl, dynlib:"libDOtherSide.so", importc.}
proc dos_qquickview_set_source(view: QQuickView, filename: cstring) {.cdecl, dynlib:"libDOtherSide.so", importc.}

proc create(view: var QQuickView) =
  ## Create a new QQuickView
  dos_qquickview_create(view)

proc source(view: QQuickView): cstring = 
  ## Return the source Qml file loaded by the view
  var length: int
  dos_qquickview_source(view, result, length)

proc `source=`(view: QQuickView, filename: cstring) =
  ## Sets the source Qml file laoded by the view
  dos_qquickview_set_source(view, filename)

proc show(view: QQuickView) = 
  ## Sets the view visible 
  dos_qquickview_show(view)

proc delete(view: QQuickView) =
  ## Delete the given QQuickView
  dos_qquickview_delete(view)

proc newQQuickView*(): QQuickView =
  # constructs a new QQuickView
  result.create
