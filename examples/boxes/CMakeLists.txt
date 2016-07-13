set(target_name boxes)
find_package(OpenGL REQUIRED)
include_directories(${OPENGL_INCLUDE_DIRS})
find_package(GLUT REQUIRED)
include_directories(${GLUT_INCLUDE_DIR})
# add_definitions( -Dwindow_debug )
add_executable(${target_name}
  ${target_name}.cc
  )
target_link_libraries(${target_name}
  ${OPENGL_LIBRARIES}
  ${GLUT_LIBRARIES}
  libnvr
  )
