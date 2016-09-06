include(../dlib/cmake)

# TODO: diable OpenCV when building with emscripten
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

#add_definitions( -Dwindow_debug )

add_library(libnvr STATIC
  nvr.cc
  )

target_include_directories(libnvr PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(libnvr
  dlib
  ${OpenCV_LIBS}
  )
