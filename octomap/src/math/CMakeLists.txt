set(octomath_SRCS Vector3.cpp Quaternion.cpp Pose6D.cpp)

if(OCTOMAP_BUILD_SHARED)
  add_library(octomath SHARED ${octomath_SRCS})
  # add alias to match exported target when calling using add_subdirectory()
  add_library(octomap::octomath ALIAS octomath)
  set_target_properties(octomath PROPERTIES VERSION ${OCTOMAP_VERSION}
                                            SOVERSION ${OCTOMAP_SOVERSION})
  target_include_directories(
    octomath PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                    $<INSTALL_INTERFACE:include>)
  list(APPEND DEFINED_TARGETS octomath)
endif()

if(OCTOMAP_BUILD_STATIC)
  add_library(octomath-static STATIC ${octomath_SRCS})
  # add alias to match exported target when calling using add_subdirectory()
  add_library(octomap::octomath-static ALIAS octomath-static)
  set_target_properties(octomath-static PROPERTIES OUTPUT_NAME "octomath")
  target_include_directories(
    octomath-static PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                           $<INSTALL_INTERFACE:include>)
  list(APPEND DEFINED_TARGETS octomath-static)
endif()

install(TARGETS ${DEFINED_TARGETS} EXPORT "${OCTOMAP_EXPORT_NAME}")

if(OCTOMAP_MASTER_PROJECT)
export(
  TARGETS ${DEFINED_TARGETS}
  APPEND
  FILE "${OCTOMAP_EXPORT_NAME}.cmake")
endif()