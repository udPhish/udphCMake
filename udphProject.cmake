function(provide_project project_name)
	if(NOT ${project_name} IN_LIST PROVIDED_PROJECTS)
		list(APPEND PROVIDED_PROJECTS ${project_name})
		set(PROVIDED_PROJECTS ${PROVIDED_PROJECTS} CACHE INTERNAL "Projects provided.")
	endif()
endfunction()
function(project_load_conan_package project_name _requires)
	string(TOLOWER ${project_name} CONAN_NAME)
	conan_basic_setup(NO_OUTPUT_DIRS)
	if(${GENERATOR_IS_MULTI_CONFIG})
		conan_cmake_configure(REQUIRES "${CONAN_NAME}/${_requires}" GENERATORS cmake_find_package_multi)
		foreach(TYPE ${CMAKE_CONFIGURATION_TYPES})
			conan_cmake_autodetect(settings BUILD_TYPE ${TYPE})
			conan_cmake_install(PATH_OR_REFERENCE .
								BUILD missing
								REMOTE conan-center
								SETTINGS ${settings})
		endforeach()
	else()
		conan_cmake_configure(REQUIRES "${CONAN_NAME}/${_requires}" GENERATORS cmake_find_package)

		conan_cmake_autodetect(settings BUILD_TYPE ${CMAKE_BUILD_TYPE})
		conan_cmake_install(PATH_OR_REFERENCE .
							BUILD missing
							REMOTE conan-center
							SETTINGS ${settings})
	endif()
	find_package(${project_name} REQUIRED)
endfunction()
function(project_load_git_repository project_name git_repository git_tag)
	set(UDPH_${project_name}_LOCATION "" CACHE PATH "Specify location for ${project_name}.")
	if(NOT ${project_name} IN_LIST PROVIDED_PROJECTS)
		if("${UDPH_${project_name}_LOCATION}" STREQUAL "")
			FetchContent_Declare(
				${project_name}
				GIT_REPOSITORY ${git_repository}
				GIT_TAG ${git_tag}
				GIT_SHALLOW ON
			)
			FetchContent_MakeAvailable(${project_name})
		else()
			FetchContent_Declare(
				${project_name}
				URL ${UDPH_${project_name}_LOCATION}
			)
			FetchContent_MakeAvailable(${project_name})
		endif()
	endif()
endfunction()
function(project_load_dir project_name fetch_dir)
	add_subdirectory(${fetch_dir} "${CMAKE_CURRENT_BINARY_DIR}/${project_name}")
endfunction()
macro(project_load_git_submodule submodule_dir submodule_repo)
	if(NOT GIT_PROJECT)
		message(FATAL_ERROR "Git is unavailable for this project.")
	endif()
	if(${ARGC} EQUAL "3")
		git_add_submodule(${submodule_dir} ${submodule_repo} ${ARGV2})
	else()
		git_add_submodule(${submodule_dir} ${submodule_repo})
	endif()
	add_subdirectory(${submodule_dir})
endmacro()
function(project_set_namespace project_name namespace)
	set(${PROJECT_NAME}_NAMESPACE ${namespace} PARENT_SCOPE)
endfunction()
macro(project_create proj_name)
	if(GIT_PROJECT)
		git_update_information(${proj_name})
		project(${proj_name} VERSION "${${proj_name}_GIT_VERSION}" LANGUAGES CXX)
	else()
		project(${proj_name} LANGUAGES CXX)
	endif()
	# Set project namespace
	set(${PROJECT_NAME}_NAMESPACE ${PROJECT_NAME})
	# Set configuration directories
	set(${PROJECT_NAME}_GENERATED_HEADER_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated_headers/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}/")
	set(${PROJECT_NAME}_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}/")
	set(${PROJECT_NAME}_CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}")
	# Set configuration files
	set(${PROJECT_NAME}_VERSION_CONFIG_FILE "${${PROJECT_NAME}_GENERATED_DIR}/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}ConfigVersion.cmake")
	set(${PROJECT_NAME}_CONFIG_FILE "${${PROJECT_NAME}_GENERATED_DIR}/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}Config.cmake")
	set(${PROJECT_NAME}_TARGETS_FILE "${PROJECT_NAME}Targets.cmake")

	set(${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_GIT_VERSION})
	set(${PROJECT_NAME}_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
	set(${PROJECT_NAME}_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
	set(${PROJECT_NAME}_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
	if("${${PROJECT_NAME}_VERSION}" STREQUAL "")
		set(${PROJECT_NAME}_VERSION_MAJOR "0")
		set(${PROJECT_NAME}_VERSION_MINOR "0")
		set(${PROJECT_NAME}_VERSION_PATCH "0")
		set(${PROJECT_NAME}_VERSION "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH}")
	endif()
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}../bin")
endmacro()

macro(finalize)
    # Configure package files
    write_basic_package_version_file(
        "${${PROJECT_NAME}_VERSION_CONFIG_FILE}"
        COMPATIBILITY
            SameMajorVersion
    )
    #TODO: config file should be named "${ProjectName}Config.cmake" after confiuration
    configure_package_config_file(
        "${UDPH_CMAKE_DIR}/udphConfig.cmake.in"
        "${${PROJECT_NAME}_CONFIG_FILE}"
        INSTALL_DESTINATION
            "${${PROJECT_NAME}_CONFIG_INSTALL_DIR}"
    )

    #########
    # INSTALL
    #########
    # Target
    install(
        TARGETS ${${PROJECT_NAME}_INSTALL_TARGETS}
        EXPORT ${${PROJECT_NAME}_TARGETS_FILE}
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    )
    # Includes
    install(
        FILES ${${PROJECT_NAME}_INSTALL_FILES}
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}"
    )
    # Headers export
    install(
        EXPORT ${${PROJECT_NAME}_TARGETS_FILE}
        NAMESPACE ${${PROJECT_NAME}_NAMESPACE}
        DESTINATION "${${PROJECT_NAME}_CONFIG_INSTALL_DIR}"
    )
    # Package files
    install(
        FILES "${${PROJECT_NAME}_CONFIG_FILE}" "${${PROJECT_NAME}_VERSION_CONFIG_FILE}"
        DESTINATION "${${PROJECT_NAME}_CONFIG_INSTALL_DIR}"
    )
    # Export build
    export(TARGETS ${${PROJECT_NAME}_INSTALL_TARGETS} NAMESPACE ${${PROJECT_NAME}_NAMESPACE}:: APPEND FILE "${${PROJECT_NAME}_TARGETS_FILE}")
    set(CMAKE_EXPORT_PACKAGE_REGISTRY ON)
    export(PACKAGE ${PROJECT_NAME})

	if(GIT_PROJECT AND GIT_CLEAN_SUBMODULES)
		foreach(ITEM ${${PROJECT_NAME}_GIT_SUBMODULES_STORED})
			if(NOT ${ITEM} IN_LIST ${PROJECT_NAME}_GIT_SUBMODULES)
				if(GIT_CLEAN_SUBMODULES_FORCE)
					execute_process(COMMAND ${GIT_EXECUTABLE} submodule deinit --force "${ITEM}"
									WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 								RESULT_VARIABLE COMMAND_RESULT)
				else()
					execute_process(COMMAND ${GIT_EXECUTABLE} submodule deinit "${ITEM}"
									WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 								RESULT_VARIABLE COMMAND_RESULT)
				endif()
				if(NOT ${COMMAND_RESULT} EQUAL "0")
					message(FATAL_ERROR "Unable to deinit submodule ${ITEM}.")
				endif()
				if(GIT_CLEAN_SUBMODULES_FORCE)
					execute_process(COMMAND ${GIT_EXECUTABLE} rm --force "${ITEM}"
									WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 								RESULT_VARIABLE COMMAND_RESULT)
				else()
					execute_process(COMMAND ${GIT_EXECUTABLE} rm "${ITEM}"
									WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 								RESULT_VARIABLE COMMAND_RESULT)
				endif()
				if(NOT ${COMMAND_RESULT} EQUAL "0")
					message(FATAL_ERROR "Unable to clean submodule ${ITEM}.")
				endif()
			endif()
		endforeach()
	endif()

	if(ENABLE_TESTING)
	  enable_testing()
	endif()

	# set(CPACK_PACKAGE_DESCRIPTION_FILE "descfile")
	set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.md")
	set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
	include(CPack)
endmacro()