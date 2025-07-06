cmake_minimum_required(VERSION 3.8)
project(robot_idl)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(arm_idl REQUIRED)
find_package(vision_idl REQUIRED)
find_package(nora_idl REQUIRED)

ament_export_dependencies(arm_idl vision_idl nora_idl)
ament_package()
