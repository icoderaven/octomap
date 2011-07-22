# Package building stuff - Experimental!
SET(CPACK_PACKAGE_VERSION "${OCTOMAP_MAJOR_VERSION}.${OCTOMAP_MINOR_VERSION}.${OCTOMAP_PATCH_VERSION}")
SET(CPACK_PACKAGE_VERSION_MAJOR "${OCTOMAP_MAJOR_VERSION}")
SET(CPACK_PACKAGE_VERSION_MINOR "${OCTOMAP_MINOR_VERSION}")
SET(CPACK_PACKAGE_VERSION_PATCH "${OCTOMAP_PATCH_VERSION}")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${V_MAJOR}.${V_MINOR}")
SET(CPACK_PACKAGE_CONTACT "K.M. Wurm and A. Hornung")
SET(CPACK_PACKAGE_VENDOR "University of Freiburg")
SET(CPACK_GENERATOR "DEB")
SET(CPACK_SOURCE_GENERATOR "TGZ")


include(CMakeModules/InstallPkgConfigFile.cmake)
install_pkg_config_file(octomap
    CFLAGS
    LIBS -loctomap -loctomath
    REQUIRES
    VERSION ${OCTOMAP_MAJOR_VERSION}.${OCTOMAP_MINOR_VERSION}.${OCTOMAP_PATCH_VERSION})

 # This must always be last statement!
INCLUDE(CPack)
