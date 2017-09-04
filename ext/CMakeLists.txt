
cmake_minimum_required(VERSION 3.0)
project(pixo)


find_package(Ruby REQUIRED)
include_directories(BEFORE ${RUBY_INCLUDE_DIRS})

#add_subdirectory(pixo)
#foreach(DERP ${PIXO_INCLUDE})
#  message(STATUS ${DERP})
#ENDFOREACH()

#include_directories(${PIXO_INCLUDE} .)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -fPIC -fpermissive")

add_library(pixgem SHARED
  gem.cpp
  )
target_link_libraries(pixgem)#  glfw libglew_static pthread  pixlib)
