set(dynamicEDT3D_SRCS dynamicEDT3D.cpp)

if(OCTOMAP_BUILD_SHARED)
  add_library(dynamicedt3d SHARED ${dynamicEDT3D_SRCS})
  # add alias to match exported target when calling using add_subdirectory()
  add_library(dynamicEDT3D::dynamicedt3d ALIAS dynamicedt3d)
  set_target_properties(
    dynamicedt3d PROPERTIES VERSION ${DYNAMICEDT3D_VERSION}
                            SOVERSION ${DYNAMICEDT3D_SOVERSION})
  target_link_libraries(dynamicedt3d octomap)
  target_include_directories(
    dynamicedt3d PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                        $<INSTALL_INTERFACE:include>)
  list(APPEND DEFINED_TARGETS dynamicedt3d)
endif()

if(OCTOMAP_BUILD_STATIC)
  add_library(dynamicedt3d-static STATIC ${dynamicEDT3D_SRCS})
  # add alias to match exported target when calling using add_subdirectory()
  add_library(dynamicEDT3D::dynamicedt3d-static ALIAS dynamicedt3d-static)
  target_link_libraries(dynamicedt3d-static octomap-static)
  target_include_directories(
    dynamicedt3d-static PRIVATE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                        INTERFACE $<INSTALL_INTERFACE:include>)
  set_target_properties(dynamicedt3d-static PROPERTIES OUTPUT_NAME
                                                       "dynamicedt3d")
  list(APPEND DEFINED_TARGETS dynamicedt3d-static)
endif()

if(NOT EXISTS "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/dynamicEDT3D")
  file(MAKE_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/dynamicEDT3D")
endif()

add_subdirectory(examples)

export(
  TARGETS ${DEFINED_TARGETS}
  FILE "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/dynamicEDT3D/dynamicEDT3DTargets.cmake"
)

# directly depend on the octomap library target when building the complete
# distribution, so it it recompiled as needed
if(OCTOMAP_BUILD_STATIC)
  add_dependencies(dynamicedt3d-static octomap-static)
endif()
if(OCTOMAP_BUILD_SHARED)
  add_dependencies(dynamicedt3d octomap)
endif()

install(TARGETS ${DEFINED_TARGETS} EXPORT dynamicEDT3DTargets)