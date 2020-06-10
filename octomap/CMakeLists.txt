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

if(INSTALL_CONFIG)

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

  set(INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/include")
  # Installation

  set(INSTALL_TARGETS_DEFAULT_ARGS
      RUNTIME
      DESTINATION
      "${CMAKE_INSTALL_BINDIR}"
      LIBRARY
      DESTINATION
      "${CMAKE_INSTALL_LIBDIR}"
      ARCHIVE
      DESTINATION
      "${CMAKE_INSTALL_LIBDIR}")

  add_subdirectory(src/math)
  add_subdirectory(src)

  file(GLOB octomap_HDRS ${PROJECT_SOURCE_DIR}/include/octomap/*.h
       ${PROJECT_SOURCE_DIR}/include/octomap/*.hxx)
  install(FILES ${octomap_HDRS}
          DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/octomap")
  file(GLOB octomap_math_HDRS ${PROJECT_SOURCE_DIR}/include/octomap/math/*.h)
  install(FILES ${octomap_math_HDRS}
          DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/octomap/math")

  # Install catkin package.xml
  install(FILES package.xml DESTINATION "${CMAKE_INSTALL_DATADIR}/octomap")

  # uninstall target
  configure_file(
    "${PROJECT_SOURCE_DIR}/CMakeModules/CMakeUninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)

  add_custom_target(
    uninstall COMMAND ${CMAKE_COMMAND} -P
                      ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

  # Export the package for use from the build-tree (this registers the build-
  # tree with a global CMake-registry)
  export(PACKAGE octomap)

  # Create a octomap-config.cmake file for the use from the build tree
  set(OCTOMAP_INCLUDE_DIRS "${INCLUDE_DIRS}")
  set(OCTOMAP_LIB_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
  # Set library names as absolute paths Windows, spec. MSVC requires the .lib
  # suffix for imported libs
  if(WIN32)
    set(OCTOMAP_LIBRARY
        "${CMAKE_IMPORT_LIBRARY_PREFIX}octomap${CMAKE_IMPORT_LIBRARY_SUFFIX}")
    set(OCTOMATH_LIBRARY
        "${CMAKE_IMPORT_LIBRARY_PREFIX}octomath${CMAKE_IMPORT_LIBRARY_SUFFIX}")
  else()
    set(OCTOMAP_LIBRARY
        "${CMAKE_SHARED_LIBRARY_PREFIX}octomap${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(OCTOMATH_LIBRARY
        "${CMAKE_SHARED_LIBRARY_PREFIX}octomath${CMAKE_SHARED_LIBRARY_SUFFIX}")
  endif()

  # not used right now (export depends?) set(OCTOMAP_CMAKE_DIR
  # "${PROJECT_BINARY_DIR}")
  include(CMakePackageConfigHelpers)

  configure_package_config_file(
    octomap-config.cmake.in
    "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap/octomap-config.cmake"
    PATH_VARS
    OCTOMAP_INCLUDE_DIRS
    OCTOMAP_LIB_DIR
    INSTALL_DESTINATION
    "${CMAKE_INSTALL_FULL_DATADIR}/octomap")

  write_basic_package_version_file(
    "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap/octomap-config-version.cmake"
    VERSION ${OCTOMAP_VERSION}
    COMPATIBILITY AnyNewerVersion)

  # Create a octomap-config.cmake file for the use from the install tree and
  # install it
  set(OCTOMAP_INCLUDE_DIRS "${CMAKE_INSTALL_FULL_INCLUDEDIR}")
  set(OCTOMAP_LIB_DIR "${CMAKE_INSTALL_FULL_LIBDIR}")
  # set(OCTOMAP_CMAKE_DIR "${INSTALL_DATA_DIR}/FooBar/CMake")

  set(OCTOMAP_INCLUDE_TARGETS
      "include(\${CMAKE_CURRENT_LIST_DIR}/octomap-targets.cmake)")

  configure_package_config_file(
    octomap-config.cmake.in
    "${PROJECT_BINARY_DIR}/InstallFiles/octomap-config.cmake"
    PATH_VARS
    OCTOMAP_INCLUDE_DIRS
    OCTOMAP_LIB_DIR
    INSTALL_DESTINATION
    "${CMAKE_INSTALL_FULL_DATADIR}/octomap")

  write_basic_package_version_file(
    ${PROJECT_BINARY_DIR}/InstallFiles/octomap-config-version.cmake
    VERSION ${OCTOMAP_VERSION}
    COMPATIBILITY AnyNewerVersion)

  install(
    FILES "${PROJECT_BINARY_DIR}/InstallFiles/octomap-config.cmake"
          "${PROJECT_BINARY_DIR}/InstallFiles/octomap-config-version.cmake"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/octomap")

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
