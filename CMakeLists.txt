cmake_minimum_required(VERSION 2.8)
project(nvr CXX)

include_directories(include)


add_compile_options( -W -Wall -Wextra -pedantic )
add_compile_options( -O3 )
add_compile_options( -march=native )

# add_compile_options( -DUSE_SSE2_INSTRUCTIONS=ON )
# add_compile_options( -DUSE_SSE4_INSTRUCTIONS=ON )
# add_compile_options( -DUSE_AVX_INSTRUCTIONS=ON )

# add_compile_options( -fsanitize=address )
# http://clang.llvm.org/docs/UsersManual.html#controlling-code-generation

#This warning is for project developers.  Use -Wno-dev to suppress it.#
#add_compile_options( -Wno-dev )


include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
  add_compile_options( -std=c++11 )
elseif(COMPILER_SUPPORTS_CXX0X)
  add_compile_options( -std=c++0x )
else()
  message(STATUS "Compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler")
endif()


add_subdirectory(libnvr)
add_subdirectory(examples)
