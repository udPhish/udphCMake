# Set project namespace
set(${PROJECT_NAME}_NAMESPACE ${PROJECT_NAME})
# Set configuration directories
set(${PROJECT_NAME}_GENERATED_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated_headers/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}/)
set(${PROJECT_NAME}_GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}/)
set(${PROJECT_NAME}_CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}")
# Set configuration files
set(${PROJECT_NAME}_VERSION_CONFIG_FILE "${${PROJECT_NAME}_GENERATED_DIR}/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}ConfigVersion.cmake")
set(${PROJECT_NAME}_CONFIG_FILE "${${PROJECT_NAME}_GENERATED_DIR}/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}Config.cmake")
set(${PROJECT_NAME}_TARGETS_FILE "${PROJECT_NAME}Targets.cmake")

# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(
    STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
  set(CMAKE_BUILD_TYPE
      RelWithDebInfo
      CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui, ccmake
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                               "MinSizeRel" "RelWithDebInfo")
endif()

# Require out-of-source builds
file(TO_CMAKE_PATH "${CMAKE_CURRENT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if(EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory.")
endif()

# Generate compile_commands.json to make it easier to work with clang based
# tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# Testing
option(ENABLE_TESTING "Enable Test Builds" ON)
if(ENABLE_TESTING)
  enable_testing()
endif()