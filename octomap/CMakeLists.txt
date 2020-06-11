cmake_minimum_required(VERSION 3.0.2)
project(octomap)

include(CTest)
include(GNUInstallDirs)

# version (e.g. for packaging)
set(OCTOMAP_MAJOR_VERSION 1)
set(OCTOMAP_MINOR_VERSION 9)
set(OCTOMAP_PATCH_VERSION 5)
set(OCTOMAP_VERSION
    ${OCTOMAP_MAJOR_VERSION}.${OCTOMAP_MINOR_VERSION}.${OCTOMAP_PATCH_VERSION})
set(OCTOMAP_SOVERSION ${OCTOMAP_MAJOR_VERSION}.${OCTOMAP_MINOR_VERSION})
if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
  if(POLICY CMP0042)
    # Enable MACOSX_RPATH by default.
    cmake_policy(SET CMP0042 NEW)
  endif(POLICY CMP0042)
endif(COMMAND cmake_policy)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMakeModules")

# COMPILER SETTINGS (default: Release) and flags
include(CompilerSettings)

# OCTOMAP_OMP = enable OpenMP parallelization (experimental, defaults to OFF)
set(OCTOMAP_OMP
    FALSE
    CACHE BOOL "Enable/disable OpenMP parallelization")
if(DEFINED ENV{OCTOMAP_OMP})
  set(OCTOMAP_OMP $ENV{OCTOMAP_OMP})
endif(DEFINED ENV{OCTOMAP_OMP})
if(OCTOMAP_OMP)
  find_package(OpenMP REQUIRED)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
  set(CMAKE_EXE_LINKER_FLAGS
      "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif(OCTOMAP_OMP)

# Installation
add_subdirectory(src/math)
add_subdirectory(src)

file(GLOB octomap_HDRS ${PROJECT_SOURCE_DIR}/include/octomap/*.h
     ${PROJECT_SOURCE_DIR}/include/octomap/*.hxx)

file(GLOB octomap_math_HDRS ${PROJECT_SOURCE_DIR}/include/octomap/math/*.h)

add_custom_target(
  uninstall COMMAND ${CMAKE_COMMAND} -P
                    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
install(FILES ${octomap_math_HDRS}
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/octomap/math")
install(FILES ${octomap_HDRS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/octomap")
# Install catkin package.xml
install(FILES package.xml DESTINATION "${CMAKE_INSTALL_DATADIR}/octomap")

include(CMakePackageConfigHelpers)
set(OCTOMAP_CMAKECONFIG_INSTALL_DIR
    "share/cmake/octomap"
    CACHE STRING "install path for octomap-config.cmake")

# Create a octomap-config.cmake file for the use from the install tree and
# install it
set(OCTOMAP_INCLUDE_DIRS "${CMAKE_INSTALL_FULL_INCLUDEDIR}")
set(OCTOMAP_LIB_DIR "${CMAKE_INSTALL_FULL_LIBDIR}")

# uninstall target
configure_file(
  "${PROJECT_SOURCE_DIR}/CMakeModules/CMakeUninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)
  
configure_package_config_file(
  octomap-config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/octomap-config.cmake
  PATH_VARS
  OCTOMAP_INCLUDE_DIRS
  OCTOMAP_LIB_DIR
  INSTALL_DESTINATION
  ${OCTOMAP_CMAKECONFIG_INSTALL_DIR})

write_basic_package_version_file(
  "octomap-config-version.cmake"
  VERSION ${OCTOMAP_VERSION}
  COMPATIBILITY AnyNewerVersion)


if(OCTOMAP_MASTER_PROJECT)
  # Export the package for use from the build-tree (this registers the build-
  # tree with a global CMake-registry)
  export(PACKAGE octomap)
  # Install the targets only if we're the Master project
  install(
    EXPORT "${OCTOMAP_EXPORT_NAME}"
    NAMESPACE "${PROJECT_NAME}::"
    DESTINATION ${OCTOMAP_CMAKECONFIG_INSTALL_DIR})

  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/octomap-config.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/octomap-config-version.cmake
          DESTINATION ${OCTOMAP_CMAKECONFIG_INSTALL_DIR})

  # Write pkgconfig-file:
  include(InstallPkgConfigFile)
  install_pkg_config_file(
    octomap
    CFLAGS
    LIBS
    -loctomap
    -loctomath
    REQUIRES
    VERSION
    ${OCTOMAP_VERSION})

  # Documentation
  find_package(Doxygen)
  if(DOXYGEN_FOUND)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/octomap.dox.in
                   ${CMAKE_CURRENT_BINARY_DIR}/octomap.dox @ONLY)
    add_custom_target(
      docs
      ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/octomap.dox
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT
        "Generating documentation (Doxygen) at location ${PROJECT_SOURCE_DIR}/doc/html/"
    )
  endif(DOXYGEN_FOUND)

  # Needs to be last statement:
  include(CPackSettings)

  # Finished:
  message(STATUS "Compile octomap using: make")
  message(STATUS "Install octomap using: make install")
  message(STATUS "    (be sure to set the correct CMAKE_INSTALL_PREFIX before)")
  message(STATUS "Compile API-documentation using: make docs")
endif()
