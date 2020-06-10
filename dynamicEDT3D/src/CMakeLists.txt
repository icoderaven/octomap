set(dynamicEDT3D_SRCS dynamicEDT3D.cpp)

if(OCTOMAP_BUILD_SHARED)
  add_library(dynamicedt3d SHARED ${dynamicEDT3D_SRCS})
  set_target_properties(
    dynamicedt3d PROPERTIES VERSION ${DYNAMICEDT3D_VERSION}
                            SOVERSION ${DYNAMICEDT3D_SOVERSION})
  target_link_libraries(dynamicedt3d ${OCTOMAP_LIBRARIES})
  list(APPEND DEFINED_TARGETS dynamicedt3d)
endif()

if(OCTOMAP_BUILD_STATIC)
  add_library(dynamicedt3d-static STATIC ${dynamicEDT3D_SRCS})
  target_link_libraries(dynamicedt3d-static ${OCTOMAP_LIBRARIES})

  set_target_properties(dynamicedt3d-static PROPERTIES OUTPUT_NAME
                                                       "dynamicedt3d")
  list(APPEND DEFINED_TARGETS dynamicedt3d-static)
endif()

if(NOT EXISTS "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/dynamicEDT3D")
  file(MAKE_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/dynamicEDT3D")
endif()

add_subdirectory(examples)

if(INSTALL_CONFIG)
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

  install(
    TARGETS ${DEFINED_TARGETS}
    EXPORT dynamicEDT3DTargets
    INCLUDES
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    ${INSTALL_TARGETS_DEFAULT_ARGS})
  install(EXPORT dynamicEDT3DTargets
          DESTINATION "${CMAKE_INSTALL_DATADIR}/dynamicEDT3D")
endif()
