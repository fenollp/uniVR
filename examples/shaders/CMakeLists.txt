set(target_name shaders)
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
  ${target_name}.cc
  )
target_link_libraries(${target_name}
  ${OPENGL_LIBRARIES}
  ${GLUT_LIBRARIES}
  ${GLEW_LIBRARIES}
  ${FreeImage_LIBRARIES}
  libnvr
  )
