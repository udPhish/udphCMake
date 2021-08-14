include("udphSettings.cmake")

if(GIT_PROJECT)
	include("udphGit.cmake")
endif()

include("udphProject.cmake")
include("udphTarget.cmake")
include("udphStaticAnalyzers.cmake")

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

