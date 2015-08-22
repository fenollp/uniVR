cmake_minimum_required(VERSION 2.8)
set(CMAKE_VERBOSE_MAKEFILE on)

PROJECT(nvr)

# set(CMAKE_EXE_LINKER_FLAGS -static)
# set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
# set(CMAKE_EXE_LINK_DYNAMIC_C_FLAGS)       # remove -Wl,-Bdynamic
# set(CMAKE_EXE_LINK_DYNAMIC_CXX_FLAGS)
# set(CMAKE_SHARED_LIBRARY_C_FLAGS)         # remove -fPIC
# set(CMAKE_SHARED_LIBRARY_CXX_FLAGS)
# set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)    # remove -rdynamic
# set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS)
# set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

# add_library(OpenCV STATIC IMPORTED)
# add_library(OpenGL STATIC IMPORTED)
# add_library(GLUT STATIC IMPORTED)

find_package(OpenCV REQUIRED)
include_directories(${OPENCV_INCLUDE_DIRS})
find_package(OpenGL REQUIRED)
include_directories(${OPENGL_INCLUDE_DIRS})
find_package(GLUT REQUIRED)
include_directories(${GLUT_INCLUDE_DIR})

include_directories(include)


add_definitions( -Wall )
add_definitions( -Wno-deprecated )
add_definitions( -W -Wextra -pedantic )
add_definitions( -O3 )
add_definitions( -march=native )

#This warning is for project developers.  Use -Wno-dev to suppress it.#
#add_definitions( -Wno-dev )


include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
  message(STATUS "Compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()




# SET(CMAKE_FIND_LIBRARY_SUFFIXES ".a" ${CMAKE_FIND_LIBRARY_SUFFIXES})
# SET(BUILD_SHARED_LIBRARIES OFF)
# set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++ -static -Bstatic")

# set(CMAKE_EXE_LINKER_FLAGS -static)
# set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
# set(CMAKE_EXE_LINK_DYNAMIC_C_FLAGS)       # remove -Wl,-Bdynamic
# set(CMAKE_EXE_LINK_DYNAMIC_CXX_FLAGS)
# set(CMAKE_SHARED_LIBRARY_C_FLAGS)         # remove -fPIC
# set(CMAKE_SHARED_LIBRARY_CXX_FLAGS)
# set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)    # remove -rdynamic
# set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS)
# set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)



if(MODE_shaders)
  set(target_name shaders)
# add_library(GLEW STATIC IMPORTED)
  find_package(GLEW REQUIRED)
  include_directories(${GLEW_INCLUDE_DIRS})
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")
# add_library(FreeImage STATIC IMPORTED)
  find_package(FreeImage REQUIRED)
  include_directories(${FreeImage_INCLUDE_DIRS})
  # add_definitions( -Dwindow_debug )
# set_target_properties(${target_name} PROPERTIES LINK_SEARCH_END_STATIC 1)
  add_executable(${target_name}
    src/nvr.cc
    src/main_${target_name}.cc
  )
  include(ext/dlib/dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    ${OPENGL_LIBRARIES}
    ${GLUT_LIBRARIES}
    ${GLEW_LIBRARIES}
    ${FreeImage_LIBRARIES}
    dlib
  )
endif(MODE_shaders)

if(MODE_boxes)
  set(target_name boxes)
# add_definitions( -Dwindow_debug )
  add_executable(${target_name}
    src/nvr.cc
    src/main_${target_name}.cc
  )
  include(ext/dlib/dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    ${OPENGL_LIBRARIES}
    ${GLUT_LIBRARIES}
    dlib
  )
endif(MODE_boxes)

if(MODE_fromfile)
  set(target_name fromfile)
  # Same as MODE_base, except no -Dwindow_debug
#  add_definitions( -Dwindow_debug )#####
  add_executable(${target_name}
    src/nvr.cc
    src/main_${target_name}.cc
  )
  include(ext/dlib/dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    dlib
  )
endif(MODE_fromfile)

if(MODE_snowmen)
  set(target_name snowmen)
  add_definitions( -Dwindow_debug )
  add_executable(${target_name}
    src/nvr.cc
    src/main_${target_name}.cc
  )
  include(ext/dlib/dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    ${OPENGL_LIBRARIES}
    ${GLUT_LIBRARIES}
    dlib
  )
endif(MODE_snowmen)

if(MODE_base)
  set(target_name base)
  add_definitions( -Dwindow_debug )
  add_executable(${target_name}
    src/nvr.cc
    src/main_${target_name}.cc
  )
  include(ext/dlib/dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    dlib
  )
endif(MODE_base)
