include(../../dlib/cmake)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

set(target_name base)
add_executable(${target_name}
  ${target_name}.cc
  )
target_link_libraries(${target_name} LINK_PUBLIC
  libnvr
  )
