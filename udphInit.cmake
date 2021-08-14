include("./udphSettings")

if(GIT_PROJECT)
	include("./udphGit")
endif()

include("./udphProject")
include("./udphTarget")
include("./udphStaticAnalyzers")

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

