include("${UDPH_CMAKE_DIR}/udphSettings.cmake")

if(GIT_PROJECT)
	include("${UDPH_CMAKE_DIR}/udphGit.cmake")
endif()

include("${UDPH_CMAKE_DIR}/udphConan.cmake")

include("${UDPH_CMAKE_DIR}/udphProject.cmake")
include("${UDPH_CMAKE_DIR}/udphTarget.cmake")
include("${UDPH_CMAKE_DIR}/udphStaticAnalyzers.cmake")

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

