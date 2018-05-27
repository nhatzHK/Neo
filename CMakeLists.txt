cmake_minimum_required(VERSION 2.8.12)

project(Neo LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(M_SRC_CPP
  src/cpp/main.cpp
  src/cpp/node.cpp
  src/cpp/connection.cpp
  src/cpp/room.cpp
)

set(M_SRC_QRC
  src/qml.qrc
)

set(M_INCLUDE
  include/node.h
  include/room.h
  include/connection.h
)

set(SOURCES
  ${M_SRC_CPP}
  ${M_INCLUDE}
  ${M_SRC_QRC}
  libs/osc/composer/OscBundleComposer.cpp
  libs/osc/composer/OscContentComposer.cpp
  libs/osc/composer/OscMessageComposer.cpp
  libs/osc/OscPatternMatching.cpp
  libs/osc/reader/OscBundle.cpp
  libs/osc/reader/OscContent.cpp
  libs/osc/reader/OscMessage.cpp
  libs/osc/reader/OscReader.cpp
  libs/osc/reader/OscValue.cpp
  libs/osc/reader/types/OscAddress.cpp
  libs/osc/reader/types/OscArrayBegin.cpp
  libs/osc/reader/types/OscArrayEnd.cpp
  libs/osc/reader/types/OscBlob.cpp
  libs/osc/reader/types/OscChar.cpp
  libs/osc/reader/types/OscDouble.cpp
  libs/osc/reader/types/OscFalse.cpp
  libs/osc/reader/types/OscFloat.cpp
  libs/osc/reader/types/OscInfinitum.cpp
  libs/osc/reader/types/OscInteger.cpp
  libs/osc/reader/types/OscLong.cpp
  libs/osc/reader/types/OscMidi.cpp
  libs/osc/reader/types/OscNil.cpp
  libs/osc/reader/types/OscRGBA.cpp
  libs/osc/reader/types/OscString.cpp
  libs/osc/reader/types/OscSymbol.cpp
  libs/osc/reader/types/OscTags.cpp
  libs/osc/reader/types/OscTimeTag.cpp
  libs/osc/reader/types/OscTrue.cpp
  libs/osc/tools/ByteBuffer.cpp
  libs/osc/tools/ByteOrder.cpp
  libs/osc/tools/NtpTimestamp.cpp
  libs/osc/composer/OscBundleComposer.h
  libs/osc/composer/OscContentComposer.h
  libs/osc/composer/OscMessageComposer.h
  libs/osc/exceptions/BooleanConversionException.h
  libs/osc/exceptions/BytesConversionException.h
  libs/osc/exceptions/CharConversionException.h
  libs/osc/exceptions/DoubleConversionException.h
  libs/osc/exceptions/FloatConversionException.h
  libs/osc/exceptions/GetBundleException.h
  libs/osc/exceptions/GetMessageException.h
  libs/osc/exceptions/IntegerConversionException.h
  libs/osc/exceptions/LongConversionException.h
  libs/osc/exceptions/MalformedArrayException.h
  libs/osc/exceptions/MalformedBundleException.h
  libs/osc/exceptions/MidiConversionException.h
  libs/osc/exceptions/OSC_ALL_EXCEPTIONS.h
  libs/osc/exceptions/OutOfBoundsReadException.h
  libs/osc/exceptions/ReadMessageException.h
  libs/osc/exceptions/RgbaConversionException.h
  libs/osc/exceptions/StringConversionException.h
  libs/osc/exceptions/SymbolConversionException.h
  libs/osc/exceptions/TimetagConversionException.h
  libs/osc/exceptions/UnknownTagException.h
  libs/osc/OscAPI.h
  libs/osc/OscPatternMatching.h
  libs/osc/OscVersion.h
  libs/osc/reader/OscBundle.h
  libs/osc/reader/OscContent.h
  libs/osc/reader/OscMessage.h
  libs/osc/reader/OscReader.h
  libs/osc/reader/types/Midi.h
  libs/osc/reader/types/OscAddress.h
  libs/osc/reader/types/OscArrayBegin.h
  libs/osc/reader/types/OscArrayEnd.h
  libs/osc/reader/types/OscBlob.h
  libs/osc/reader/types/OscChar.h
  libs/osc/reader/types/OscDouble.h
  libs/osc/reader/types/OscFalse.h
  libs/osc/reader/types/OscFloat.h
  libs/osc/reader/types/OscInfinitum.h
  libs/osc/reader/types/OscInteger.h
  libs/osc/reader/types/OscLong.h
  libs/osc/reader/types/OscMidi.h
  libs/osc/reader/types/OscNil.h
  libs/osc/reader/types/OscRGBA.h
  libs/osc/reader/types/OscString.h
  libs/osc/reader/types/OscSymbol.h
  libs/osc/reader/types/OscTags.h
  libs/osc/reader/types/OscTimetag.h
  libs/osc/reader/types/OscTrue.h
  libs/osc/reader/types/OscValue.h
  libs/osc/reader/types/RGBA.h
  libs/osc/reader/types/Symbol.h
  libs/osc/tools/ByteBuffer.h
  libs/osc/tools/ByteOrder.h
  libs/osc/tools/exceptions/BufferOverflowException.h
  libs/osc/tools/exceptions/BufferUnderflowException.h
  libs/osc/tools/exceptions/IllegalArgumentException.h
  libs/osc/tools/exceptions/IndexOutOfBoundsException.h
  libs/osc/tools/NtpTimestamp.h
)

find_package(Qt5 COMPONENTS Core Quick Sql REQUIRED)

add_executable(${PROJECT_NAME} ${SOURCES})

include_directories(include libs)
target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Sql)
