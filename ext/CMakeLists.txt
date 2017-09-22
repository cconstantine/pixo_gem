
cmake_minimum_required(VERSION 3.0)
project(pixo)

if (APPLE)
  set(CMAKE_FIND_FRAMEWORK LAST)
  set(CMAKE_FIND_APPBUNDLE LAST)
endif()

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/libpixgem/include )
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/pixo EXCLUDE_FROM_ALL)
include_directories(${PIXLIB_INCLUDE})

foreach(inc ${PIXLIB_INCLUDE})
  message(STATUS ${inc})
endforeach()

find_package(Ruby REQUIRED)
include_directories(BEFORE ${RUBY_INCLUDE_DIRS})


set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -fPIC -fpermissive")

add_library(pixgem SHARED
  libpixgem/src/gem.cpp
  libpixgem/src/holder.cpp
  libpixgem/src/application.cpp
  libpixgem/src/pattern.cpp
  libpixgem/src/fade_candy.cpp
  libpixgem/src/camera.cpp
  )


if (APPLE)
  set_target_properties(pixgem
    PROPERTIES
    SUFFIX ".bundle"
    LINK_FLAGS "-flat_namespace" )
endif()


target_link_libraries(pixgem glfw libglew_static pthread  pixlib ${RUBY_LIBRARY})

# Ruby gems require a install target.
install(TARGETS pixgem
            RUNTIME DESTINATION lib/
            ARCHIVE DESTINATION lib/
            LIBRARY DESTINATION lib/
        )