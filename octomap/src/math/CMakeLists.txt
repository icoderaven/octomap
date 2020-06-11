set(octomath_SRCS Vector3.cpp Quaternion.cpp Pose6D.cpp)

if(OCTOMAP_BUILD_SHARED)
  add_library(octomath SHARED ${octomath_SRCS})
  set_target_properties(octomath PROPERTIES VERSION ${OCTOMAP_VERSION}
                                            SOVERSION ${OCTOMAP_SOVERSION})
  target_include_directories(
    octomath PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                    $<INSTALL_INTERFACE:include>)
  list(APPEND DEFINED_TARGETS octomath)
endif()

if(OCTOMAP_BUILD_STATIC)
  add_library(octomath-static STATIC ${octomath_SRCS})
  set_target_properties(octomath-static PROPERTIES OUTPUT_NAME "octomath")
  target_include_directories(
    octomath-static PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                           $<INSTALL_INTERFACE:include>)
  list(APPEND DEFINED_TARGETS octomath-static)
endif()

export(
  TARGETS ${DEFINED_TARGETS}
  APPEND
  FILE "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap/octomap-targets.cmake")

if(NOT EXISTS "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap")
  file(MAKE_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap")
endif()

install(TARGETS ${DEFINED_TARGETS} EXPORT "${OCTOMAP_EXPORT_NAME}")