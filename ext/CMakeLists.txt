
cmake_minimum_required(VERSION 3.0)
project(pixo)


include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/pixo_native/include )
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/pixo EXCLUDE_FROM_ALL)
include_directories(${PIXLIB_INCLUDE})

foreach(inc ${PIXLIB_INCLUDE})
  message(STATUS ${inc})
endforeach()

find_package(Ruby REQUIRED)
include_directories(BEFORE ${RUBY_INCLUDE_DIRS})


set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -fPIC -fpermissive")

add_library(pixgem SHARED
  pixo_native/src/gem.cpp
  )
target_link_libraries(pixgem glfw libglew_static pthread  pixlib)

# Ruby gems require a install target.
install(TARGETS pixgem
            RUNTIME DESTINATION lib/
            ARCHIVE DESTINATION lib/
            LIBRARY DESTINATION lib/
        )