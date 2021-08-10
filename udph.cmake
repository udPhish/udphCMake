set(CMAKE_UDPH_PATH "${CMAKE_CURRENT_LIST_DIR}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_UDPH_PATH}")

include(udphSettings)

if(GIT_PROJECT)
	include(udphGit)
endif()
include(udphProject)
include(udphTarget)
include(udphStaticAnalyzers)

include(GNUInstallDirs)
include(FetchContent)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)