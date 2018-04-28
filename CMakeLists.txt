cmake_minimum_required(VERSION 2.8.12)

project(Neo LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick Sql REQUIRED)

add_executable(${PROJECT_NAME}
  src/cpp/main.cpp
  src/cpp/inputnode.cpp
  src/cpp/connection.cpp
  src/cpp/room.cpp
  include/inputnode.h
  include/room.h
  include/connection.h
  src/qml.qrc)

include_directories(include)
target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Sql)
