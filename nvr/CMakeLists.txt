cmake_minimum_required(VERSION 2.6)

set(target_name nvr)
PROJECT(${target_name})

find_package(OpenCV REQUIRED)
include_directories(${OPENCV_INCLUDE_DIRS})

find_package(OpenGL REQUIRED)
include_directories(${OPENGL_INCLUDE_DIRS})
find_package(GLUT REQUIRED)
include_directories(${GLUT_INCLUDE_DIR})

include_directories(include)


set(nvr__src
  src/nvr.cc
)

set(nvr__libs
  ${OpenCV_LIBS}
  ${OPENGL_LIBRARIES}
  ${GLUT_LIBRARIES}
  dlib
)

#if(snowmen)
  set(nvr__src
    ${nvr__src}
    src/main_snowmen.cc
  )
#endif(snowmen)

add_definitions( -Wall )
add_definitions( -Wno-deprecated )
#add_definitions( -W -Wextra -pedantic )

# add all the cpp files we want to compile to this list.  This tells
# cmake that they are part of our target (which is the executable named dtest)
ADD_EXECUTABLE(${target_name} ${nvr__src})

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


# Tell cmake to link our target executable to dlib.
include(ext/dlib/dlib/cmake)
TARGET_LINK_LIBRARIES(${target_name}
  ${OpenCV_LIBS}
  ${OPENGL_LIBRARIES}
  ${GLUT_LIBRARIES}
  dlib
)


# if (NOT DLIB_NO_GUI_SUPPORT)
#    add_subdirectory(gui)
#    add_subdirectory(examples)
# endif()
