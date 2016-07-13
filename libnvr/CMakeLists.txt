include(../dlib/cmake)

# TODO: diable when building with emscripten
find_package(OpenCV REQUIRED)
include_directories(${OPENCV_INCLUDE_DIRS})


add_library(libnvr  SHARED nvr.cc)
add_library(libnvr_ STATIC nvr.cc)

target_link_libraries(libnvr  dlib ${OpenCV_LIBS})
target_link_libraries(libnvr_ dlib ${OpenCV_LIBS})
