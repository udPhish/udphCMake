include("${CMAKE_UDPH_PATH}/udphSettings")

if(GIT_PROJECT)
	include("${CMAKE_UDPH_PATH}/udphGit")
endif()

include("${CMAKE_UDPH_PATH}/udphProject")
include("${CMAKE_UDPH_PATH}/udphTarget")
include("${CMAKE_UDPH_PATH}/udphStaticAnalyzers")

include(GNUInstallDirs)
include(FetchContent)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

