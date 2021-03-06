cmake_minimum_required(VERSION 3.0.2)
project(octomap-distribution)

# Check if this CMakeLists is being used directly or via add_subdirectory
set(OCTOMAP_MASTER_PROJECT OFF)
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  set(OCTOMAP_MASTER_PROJECT ON)
endif()
# Allow for parent CMakeLists to populate the outgoing targets file
if(NOT OCTOMAP_EXPORT_NAME)
  set(OCTOMAP_EXPORT_NAME "octomap-targets")
endif()
message(STATUS "[octomap]:: Export name is ${OCTOMAP_EXPORT_NAME}")

enable_testing() # enable CTest environment of subprojects

set(CMAKE_POSITION_INDEPENDENT_CODE ON) # enables -fPIC in applicable compilers
                                        # (required to avoid link errors in some
                                        # cases)
option(OCTOMAP_BUILD_STATIC "Build Static libraries" ON)
option(OCTOMAP_BUILD_SHARED "Build Shared libraries" ON)
option(OCTOMAP_BUILD_ONLY_LIB "Only build libraries" OFF)
option(BUILD_OCTOVIS_SUBPROJECT "Build targets from subproject octovis" ON)
option(BUILD_DYNAMICEDT3D_SUBPROJECT
       "Build targets from subproject dynamicEDT3D" ON)
option(OCTOVIS_QT5 "Link Octovis against Qt5?" ON)

if(OCTOVIS_QT5)
  # Compiling against QT5 requires C++11.
  set(CMAKE_CXX_STANDARD 11)
endif(OCTOVIS_QT5)

add_subdirectory(octomap)

if(BUILD_OCTOVIS_SUBPROJECT)
  add_subdirectory(octovis)
endif()

if(BUILD_DYNAMICEDT3D_SUBPROJECT)
  add_subdirectory(dynamicEDT3D)
endif()
