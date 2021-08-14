set(UDPH_CMAKE_VERSION master CACHE STRING "Git tag or branch for udphCMake.")

include(FetchContent)
FetchContent_Declare(
	"updhCMake_${UDPH_CMAKE_VERSION}"
	GIT_REPOSITORY "https://github.com/udPhish/udphCMake.git"
	GIT_TAG "${UDPH_CMAKE_VERSION}"
)
string(TOLOWER "updhCMake_${UDPH_CMAKE_VERSION}" lcName)
if(NOT ${lcName}_POPULATED)
	FetchContent_Populate(${lcName})

endif()

include("${${lcName}_SOURCE_DIR}/udphInit")