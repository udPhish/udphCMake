# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE)
  message(
    STATUS "Setting build type as none was specified.")
  set(CMAKE_BUILD_TYPE
      RelWithDebInfo
      CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui, ccmake
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                               "MinSizeRel" "RelWithDebInfo")
endif()
if(NOT CMAKE_CONFIGURATION_TYPES)
  message(
    STATUS "Setting multi-configuration types as none were specified.")
  set(CMAKE_CONFIGURATION_TYPES
      "Debug;Release;MinSizeRel;RelWithDebInfo"
      CACHE STRING "Choose multi-configuration build types." FORCE)
endif()

# Require out-of-source builds
file(TO_CMAKE_PATH "${CMAKE_CURRENT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if(EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory.")
endif()

# Generate compile_commands.json to make it easier to work with clang based
# tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


option(ENABLE_TESTING "Enable Test Builds" ON)

option(GIT_PROJECT "Project uses Git." ON)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)