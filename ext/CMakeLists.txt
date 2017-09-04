
cmake_minimum_required(VERSION 3.0)
project(pixo)


find_package(Ruby REQUIRED)
include_directories(BEFORE ${RUBY_INCLUDE_DIRS})

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/pixo EXCLUDE_FROM_ALL)
include_directories(${PIXO_INCLUDE} .)


###################### GLFW     ################################
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL " " FORCE)
set(GLFW_BUILD_TESTS    OFF CACHE BOOL " " FORCE)
set(GLFW_BUILD_DOCS     OFF CACHE BOOL " " FORCE)
set(GLFW_INSTALL        OFF CACHE BOOL " " FORCE)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/glfw EXCLUDE_FROM_ALL)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -fPIC -fpermissive")

add_library(pixgem SHARED
  gem.cpp
  )
target_link_libraries(pixgem glfw libglew_static pthread  pixlib)

# Ruby gems require a install target.
install(TARGETS pixgem
            RUNTIME DESTINATION lib/
            ARCHIVE DESTINATION lib/
            LIBRARY DESTINATION lib/
        )