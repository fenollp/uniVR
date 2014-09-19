cmake_minimum_required(VERSION 2.6)

find_package(OpenCV REQUIRED)
include_directories(${OPENCV_INCLUDE_DIRS})
include_directories(include)


set (nvr__src
  src/main.cc
  )

set (target_name nvr)

PROJECT(${target_name})

# add all the cpp files we want to compile to this list.  This tells
# cmake that they are part of our target (which is the executable named dtest)
ADD_EXECUTABLE(${target_name} ${nvr__src})

# Turn on all warnings when using gcc.
if (CMAKE_COMPILER_IS_GNUCXX)
   add_definitions("-W -Wall")
endif()


#This warning is for project developers.  Use -Wno-dev to suppress it.#
add_definitions( -Wno-dev )


# Tell cmake to link our target executable to dlib.
include(deps/dlib/dlib/cmake)
TARGET_LINK_LIBRARIES(${target_name}
  ${OpenCV_LIBS}
  dlib
)


# if (NOT DLIB_NO_GUI_SUPPORT)
#    add_subdirectory(gui)
#    add_subdirectory(examples)
# endif()



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
