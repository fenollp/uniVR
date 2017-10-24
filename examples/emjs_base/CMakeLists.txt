set(target_name emjs_base)
include_directories( ../../libnvr/ . )
add_compile_options( -v )
#  add_compile_options( --js-library 'libnvr/emscripten/library_html5video.js )
add_definitions( --preload-file 'data/crate.bmp' )
add_definitions( --preload-file 'data/68/shape_predictor_68_face_landmarks.dat' )
add_definitions( -s TOTAL_MEMORY='218103808' )
# --memory-init-file 0
set(CMAKE_EXECUTABLE_SUFFIX ".html")
#set_target_properties(${target_name} PROPERTIES LINK_FLAGS "--js-library libnvr/emscripten/library_html5video.js")
#add_definitions( --js-library libnvr/emscripten/library_html5video.js )
#add_compile_options( --js-library libnvr/emscripten/library_html5video.js )
# get_filename_component(js_file_absolute_path "libnvr/emscripten/library_html5video.js" ABSOLUTE )
# target_link_libraries(${target_name} "--js-library \"${js_file_absolute_path}\"")
#  set (CMAKE_SHARED_LINKER_FLAGS "--js-library libnvr/emscripten/library_html5video.js")
get_filename_component(js_file_absolute_path "libnvr/emscripten/library_html5video.js" ABSOLUTE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --js-library \"${js_file_absolute_path}\"")
# em_link_js_library(${target_name}
#   libnvr/emscripten/library_html5video.js
#   )
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s DISABLE_EXCEPTION_CATCHING=0")
add_executable(${target_name}
  ../../dlib/base64/base64_kernel_1.cpp
  ../../dlib/entropy_decoder/entropy_decoder_kernel_2.cpp
  ../../libnvr/nvr.cc
  ${target_name}.cc
  )
