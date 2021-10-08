include(../../dlib/dlib/cmake)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

set(target_name base)
add_executable(${target_name}
  ${target_name}.cc
  )
target_link_libraries(${target_name} LINK_PUBLIC
  libnvr
  )

# cd dlib-19.1 && sudo python2 setup.py install --yes USE_AVX_INSTRUCTIONS
# sudo apt-get install libboost-python-dev
# pip install scikit-image
# sudo apt-get install python-sklearn
