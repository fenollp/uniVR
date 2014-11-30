cmake_minimum_required(VERSION 2.6)

PROJECT(nvr)

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
        message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()


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

if(MODE_fromfile)
  set(target_name fromfile)
  # Same as MODE_base, except no -Dwindow_debug
  add_definitions( -Dwindow_debug )#####
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


# if (NOT DLIB_NO_GUI_SUPPORT)
#    add_subdirectory(gui)
#    add_subdirectory(examples)
# endif()
