set(target_name base)
add_definitions( -Dwindow_debug )
add_executable(${target_name}
  ${target_name}.cc
  )
target_link_libraries(${target_name}
  libnvr
  )
