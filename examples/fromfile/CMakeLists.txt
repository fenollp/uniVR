# Same as MODE_base, except no -Dwindow_debug
set(target_name fromfile)
add_executable(${target_name}
  ${target_name}.cc
  )
target_link_libraries(${target_name}
  libnvr
  )
