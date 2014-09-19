cmake_minimum_required(VERSION 2.6)

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


# Tell cmake to link our target executable to dlib.
include(deps/dlib/dlib/cmake)
TARGET_LINK_LIBRARIES(${target_name} dlib)


# if (NOT DLIB_NO_GUI_SUPPORT)
#    add_subdirectory(gui)
#    add_subdirectory(examples)
# endif()

