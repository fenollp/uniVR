cmake_minimum_required(VERSION 2.8)
PROJECT(nvr)

include_directories(include)


add_definitions( -Wall )
add_definitions( -Wno-deprecated )
add_definitions( -W -Wextra -pedantic )
add_definitions( -O3 )
add_definitions( -march=native )

# add_definitions( -DUSE_SSE2_INSTRUCTIONS=ON )
# add_definitions( -DUSE_SSE4_INSTRUCTIONS=ON )
# add_definitions( -DUSE_AVX_INSTRUCTIONS=ON )

# add_definitions( -fsanitize=address )
# http://clang.llvm.org/docs/UsersManual.html#controlling-code-generation

#This warning is for project developers.  Use -Wno-dev to suppress it.#
#add_definitions( -Wno-dev )


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


if(MODE_emjs_base)
  set(target_name emjs_base)
  include_directories(lib/ .)
  add_compile_options( -v )
#  add_compile_options( --js-library 'lib/emscripten/library_html5video.js )
  add_definitions( --preload-file 'data/crate.bmp' )
  add_definitions( --preload-file 'data/ldmrks68.dat' )
  add_definitions( -s TOTAL_MEMORY='218103808' )
  # --memory-init-file 0
  set(CMAKE_EXECUTABLE_SUFFIX ".html")
  #set_target_properties(${target_name} PROPERTIES LINK_FLAGS "--js-library lib/emscripten/library_html5video.js")
  #add_definitions( --js-library lib/emscripten/library_html5video.js )
  #add_compile_options( --js-library lib/emscripten/library_html5video.js )
  # get_filename_component(js_file_absolute_path "lib/emscripten/library_html5video.js" ABSOLUTE )
  # target_link_libraries(${target_name} "--js-library \"${js_file_absolute_path}\"")
  #  set (CMAKE_SHARED_LINKER_FLAGS "--js-library lib/emscripten/library_html5video.js")
  get_filename_component(js_file_absolute_path "lib/emscripten/library_html5video.js" ABSOLUTE )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --js-library \"${js_file_absolute_path}\"")
  # em_link_js_library(${target_name}
  #   lib/emscripten/library_html5video.js
  #   )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s DISABLE_EXCEPTION_CATCHING=0")
  add_executable(${target_name}
    dlib/base64/base64_kernel_1.cpp
    dlib/entropy_decoder/entropy_decoder_kernel_2.cpp
    lib/emjs.cc
    src/main_emjs_base.cc
    )
endif(MODE_emjs_base)


if(MODE_shaders)
  set(target_name shaders)
  find_package(OpenCV REQUIRED)
  include_directories(${OPENCV_INCLUDE_DIRS})
  find_package(OpenGL REQUIRED)
  include_directories(${OPENGL_INCLUDE_DIRS})
  find_package(GLUT REQUIRED)
  include_directories(${GLUT_INCLUDE_DIR})
  find_package(GLEW REQUIRED)
  include_directories(${GLEW_INCLUDE_DIRS})
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")
  find_package(FreeImage REQUIRED)
  include_directories(${FreeImage_INCLUDE_DIRS})
  # add_definitions( -Dwindow_debug )
  add_executable(${target_name}
    lib/nvr.cc
    src/main_${target_name}.cc
  )
  include(dlib/cmake)
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
  find_package(OpenCV REQUIRED)
  include_directories(${OPENCV_INCLUDE_DIRS})
  find_package(OpenGL REQUIRED)
  include_directories(${OPENGL_INCLUDE_DIRS})
  find_package(GLUT REQUIRED)
  include_directories(${GLUT_INCLUDE_DIR})
# add_definitions( -Dwindow_debug )
  add_executable(${target_name}
    lib/nvr.cc
    src/main_${target_name}.cc
  )
  include(dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    ${OPENGL_LIBRARIES}
    ${GLUT_LIBRARIES}
    dlib
  )
endif(MODE_boxes)

if(MODE_fromfile) # Same as MODE_base, except no -Dwindow_debug
  set(target_name fromfile)
  find_package(OpenCV REQUIRED)
  include_directories(${OPENCV_INCLUDE_DIRS})
  add_executable(${target_name}
    lib/nvr.cc
    src/main_${target_name}.cc
  )
  include(dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    dlib
  )
endif(MODE_fromfile)

if(MODE_base)
  set(target_name base)
  find_package(OpenCV REQUIRED)
  include_directories(${OPENCV_INCLUDE_DIRS})
  add_definitions( -Dwindow_debug )
  add_executable(${target_name}
    lib/nvr.cc
    src/main_${target_name}.cc
  )
  include(dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    dlib
  )
endif(MODE_base)

if(MODE_snowmen) # What it used to be like
  set(target_name snowmen)
  find_package(OpenCV REQUIRED)
  include_directories(${OPENCV_INCLUDE_DIRS})
  find_package(OpenGL REQUIRED)
  include_directories(${OPENGL_INCLUDE_DIRS})
  find_package(GLUT REQUIRED)
  include_directories(${GLUT_INCLUDE_DIR})
  add_definitions( -Dwindow_debug )
  add_executable(${target_name}
    lib/nvr.cc
    src/main_${target_name}.cc
  )
  include(dlib/cmake)
  target_link_libraries(${target_name}
    ${OpenCV_LIBS}
    ${OPENGL_LIBRARIES}
    ${GLUT_LIBRARIES}
    dlib
  )
endif(MODE_snowmen)
