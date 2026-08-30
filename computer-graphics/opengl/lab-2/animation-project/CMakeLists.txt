cmake_minimum_required(VERSION 4.2)
project(AnimationProject LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenGL REQUIRED)

# Point this at a local GLFW checkout, e.g.
#   cmake -DGLFW_SOURCE_DIR=/path/to/glfw-3.4 ..
set(GLFW_SOURCE_DIR "" CACHE PATH "Path to the GLFW source tree")

if(NOT GLFW_SOURCE_DIR)
    message(FATAL_ERROR "GLFW_SOURCE_DIR is not set")
endif()

add_subdirectory(
        ${GLFW_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}/glfw
)

add_executable(AnimationProject main.cpp)

target_link_libraries(AnimationProject PRIVATE glfw OpenGL::GL)
