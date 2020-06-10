set(octomath_SRCS Vector3.cpp Quaternion.cpp Pose6D.cpp)

add_library(octomath SHARED ${octomath_SRCS})

set_target_properties(octomath PROPERTIES VERSION ${OCTOMAP_VERSION}
                                          SOVERSION ${OCTOMAP_SOVERSION})

add_library(octomath-static STATIC ${octomath_SRCS})
set_target_properties(octomath-static PROPERTIES OUTPUT_NAME "octomath")
target_include_directories(
  octomath PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                  $<INSTALL_INTERFACE:include>)

target_include_directories(
  octomath-static PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                  $<INSTALL_INTERFACE:include>)

if(INSTALL_CONFIG)
  if(NOT EXISTS "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap")
    file(MAKE_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap")
  endif()

  export(
    TARGETS octomath octomath-static
    APPEND
    FILE "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap/octomap-targets.cmake"
  )

  install(
    TARGETS octomath octomath-static
    EXPORT octomap-targets
    INCLUDES
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    ${INSTALL_TARGETS_DEFAULT_ARGS})
endif()
