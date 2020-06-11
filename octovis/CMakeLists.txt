cmake_minimum_required(VERSION 3.11)
project(octovis)

include(CTest)
include(GNUInstallDirs)

# # version (e.g. for packaging)
set(OCTOVIS_MAJOR_VERSION 1)
set(OCTOVIS_MINOR_VERSION 9)
set(OCTOVIS_PATCH_VERSION 5)
set(OCTOVIS_VERSION
    ${OCTOVIS_MAJOR_VERSION}.${OCTOVIS_MINOR_VERSION}.${OCTOVIS_PATCH_VERSION})
set(OCTOVIS_SOVERSION ${OCTOVIS_MAJOR_VERSION}.${OCTOVIS_MINOR_VERSION})
# get rid of a useless warning:
if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
  if(POLICY CMP0042)
    # Enable MACOSX_RPATH by default.
    cmake_policy(SET CMP0042 NEW)
  endif(POLICY CMP0042)
endif(COMMAND cmake_policy)
cmake_policy(SET CMP0072 OLD) # Prefer GLVND by default when available (CMake 3.11+)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMakeModules")

# COMPILER SETTINGS (default: Release) and flags
include(CompilerSettings)

# Set output directories for libraries and executables
set(BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${BASE_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${BASE_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BASE_DIR}/bin)
# output dirs for multi-config builds (MSVC)
foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
  string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${BASE_DIR}/lib)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${BASE_DIR}/lib)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${BASE_DIR}/bin)
endforeach(OUTPUTCONFIG CMAKE_CONFIGURATION_TYPES)

# Builds the "octovis" viewer based on OpenGL and libQGLViewer, if dependencies
# available
set(BUILD_VIEWER 0)

option(OCTOVIS_QT5 "Link Octovis against Qt5?" ON)

# Look for required libraries:
find_package(OpenGL)
if(NOT OCTOVIS_QT5)
  find_package(Qt4)
endif(NOT OCTOVIS_QT5)

if(OpenGL-NOTFOUND OR Qt4-NOTFOUND)
  message("OpenGL and QT4 are required for octovis but could not be found.")
else()
  find_package(QGLViewer)
  if(QGLViewer_FOUND)
    set(BUILD_VIEWER 1)
  else()
    message("libQGLViewer could not be found or generated.")
  endif()
endif()

if(BUILD_VIEWER)
  message(STATUS "viewer octovis will be built")

  include(CMakeLists_src.txt)

  # #installation: # store all header files to install:
  file(GLOB octovis_HDRS *.h *.hxx *.hpp)
  install(FILES ${octovis_HDRS}
          DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/octovis")

  # Install catkin package.xml
  install(FILES package.xml DESTINATION "share/octovis")

  # Set library names as absolute paths Windows, spec. MSVC requires the .lib
  # suffix for imported libs
  if(WIN32)
    set(OCTOVIS_LIBRARY
        "${CMAKE_IMPORT_LIBRARY_PREFIX}octovis${CMAKE_IMPORT_LIBRARY_SUFFIX}")
  else()
    set(OCTOVIS_LIBRARY
        "${CMAKE_SHARED_LIBRARY_PREFIX}octovis${CMAKE_SHARED_LIBRARY_SUFFIX}")
  endif()

  include(CMakePackageConfigHelpers)
  set(OCTOVIS_CMAKECONFIG_INSTALL_DIR
      "share/cmake/octovis"
      CACHE STRING "install path for octovis-config.cmake")

  # Create a octovis-config.cmake file for the use from the install tree and
  # install it
  set(OCTOVIS_INCLUDE_DIRS include/)
  set(OCTOVIS_LIB_DIR libs/)

  configure_package_config_file(
    octovis-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/octovis-config.cmake
    PATH_VARS
    OCTOVIS_INCLUDE_DIRS
    OCTOVIS_LIB_DIR
    INSTALL_DESTINATION
    ${OCTOVIS_CMAKECONFIG_INSTALL_DIR})

  write_basic_package_version_file(
    octovis-config-version.cmake
    VERSION ${OCTOVIS_VERSION}
    COMPATIBILITY AnyNewerVersion)

  if(OCTOMAP_MASTER_PROJECT)
    install(
      EXPORT octovis-targets
      NAMESPACE "${PROJECT_NAME}::"
      DESTINATION "share/cmake/octovis")

    # Export the package for use from the build-tree (this registers the build-
    # tree with a global CMake-registry)
    export(PACKAGE octovis)

    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/octovis-config.cmake
                  ${CMAKE_CURRENT_BINARY_DIR}/octovis-config-version.cmake
            DESTINATION ${OCTOVIS_CMAKECONFIG_INSTALL_DIR})
  endif()

else()
  message(
    "Unfortunately, the viewer (octovis) can not be built because some requirements are missing."
  )
  message(
    "This will not affect the compilation of the stand-alone library and tools (octomap)"
  )
  message("See README.txt or http://octomap.sf.net for further information.\n")
endif()
