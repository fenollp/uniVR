cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(algo_haar_ocl CXX)
#set (CMAKE_VERBOSE_MAKEFILE true)

find_package(OpenCV 3 REQUIRED)
include_directories(${OPENCV_INCLUDE_DIRS})

set(algo_haar_ocl__src
    main.cc
)

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

# Must be same libc++ than OpenCV's
#   http://stackoverflow.com/questions/19119445/error-when-using-imshow-on-os-x
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++")
# …but GCC has issues recognising this option(wth),
#   so set your CC & CXX (env variables) to clang & clang++ ('s paths) resp.


add_executable(algo_haar_ocl ${algo_haar_ocl__src})

target_link_libraries(algo_haar_ocl ${OpenCV_LIBS})
