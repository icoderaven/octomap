set(octomap_SRCS
    AbstractOcTree.cpp
    AbstractOccupancyOcTree.cpp
    Pointcloud.cpp
    ScanGraph.cpp
    CountingOcTree.cpp
    OcTree.cpp
    OcTreeNode.cpp
    OcTreeStamped.cpp
    ColorOcTree.cpp)

# dynamic and static libs, see CMake FAQ:
if(OCTOMAP_BUILD_SHARED)
  add_library(octomap SHARED ${octomap_SRCS})
  set_target_properties(octomap PROPERTIES VERSION ${OCTOMAP_VERSION}
                                           SOVERSION ${OCTOMAP_SOVERSION})
  target_include_directories(
    octomap PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                   $<INSTALL_INTERFACE:include>)
  target_link_libraries(octomap octomath)
  list(APPEND DEFINED_TARGETS octomap)
endif()

if(OCTOMAP_BUILD_STATIC)
  add_library(octomap-static STATIC ${octomap_SRCS})
  set_target_properties(octomap-static PROPERTIES OUTPUT_NAME "octomap")

  add_dependencies(octomap-static octomath-static)
  target_include_directories(
    octomap-static PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/>
                          $<INSTALL_INTERFACE:include>)
  list(APPEND DEFINED_TARGETS octomap-static)
endif()

if(NOT EXISTS "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap")
  file(MAKE_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap")
endif()

if(NOT OCTOMAP_BUILD_ONLY_LIB)
  add_subdirectory(testing)

  add_executable(graph2tree graph2tree.cpp)
  target_link_libraries(graph2tree octomap)

  add_executable(log2graph log2graph.cpp)
  target_link_libraries(log2graph octomap)

  add_executable(binvox2bt binvox2bt.cpp)
  target_link_libraries(binvox2bt octomap)

  add_executable(bt2vrml bt2vrml.cpp)
  target_link_libraries(bt2vrml octomap)

  add_executable(edit_octree edit_octree.cpp)
  target_link_libraries(edit_octree octomap)

  add_executable(convert_octree convert_octree.cpp)
  target_link_libraries(convert_octree octomap)

  add_executable(eval_octree_accuracy eval_octree_accuracy.cpp)
  target_link_libraries(eval_octree_accuracy octomap)

  add_executable(compare_octrees compare_octrees.cpp)
  target_link_libraries(compare_octrees octomap)

  add_executable(simple_example simple_example.cpp)
  target_link_libraries(simple_example octomap)

  add_executable(normals_example normals_example.cpp)
  target_link_libraries(normals_example octomap)

  add_executable(intersection_example intersection_example.cpp)
  target_link_libraries(intersection_example octomap)

  add_executable(octree2pointcloud octree2pointcloud.cpp)
  target_link_libraries(octree2pointcloud octomap)
endif()

export(
  TARGETS ${DEFINED_TARGETS}
  APPEND
  FILE "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/octomap/octomap-targets.cmake"
)

if(INSTALL_CONFIG)

  install(
    TARGETS ${DEFINED_TARGETS}
    EXPORT octomap-targets
    INCLUDES
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    ${INSTALL_TARGETS_DEFAULT_ARGS})
  install(EXPORT octomap-targets DESTINATION "${CMAKE_INSTALL_DATADIR}/octomap")

  if(NOT OCTOMAP_BUILD_ONLY_LIB)
    install(
      TARGETS graph2tree
              log2graph
              binvox2bt
              bt2vrml
              edit_octree
              convert_octree
              eval_octree_accuracy
              compare_octrees
              ${INSTALL_TARGETS_DEFAULT_ARGS})
  endif()
endif()
