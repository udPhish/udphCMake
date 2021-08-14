option(GIT_FETCH_SUBMODULES "Check submodules during build" ON)
option(GIT_CLEAN_SUBMODULES "Remove any submodules not added using git_add_submodule" OFF)
option(GIT_CLEAN_SUBMODULES_FORCE "Ignore uncommited changes when cleaning submodules" OFF)

find_package(Git REQUIRED)

if(NOT GIT_FOUND)
	message(FATAL_ERROR "Git not found.")
elseif(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git")
	message(FATAL_ERROR "Git project not initialized.")
endif()

if(GIT_NORMALIZE_LINE_ENDINGS)
	if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
		execute_process(COMMAND ${GIT_EXECUTABLE} config --global core.autocrlf true
						WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
	else()
		execute_process(COMMAND ${GIT_EXECUTABLE} config --global core.autocrlf input
						WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
	endif()
endif()

function(git_update_information proj_name)
	#Get Git describe
	execute_process(COMMAND ${GIT_EXECUTABLE} describe --dirty
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			RESULT_VARIABLE res
			OUTPUT_VARIABLE GIT_DESCRIBE
			ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

	#Get Git version
	if(NOT ${GIT_DESCRIBE} STREQUAL "")
		string(FIND ${GIT_DESCRIBE} "-" GIT_INDEX)
		string(SUBSTRING ${GIT_DESCRIBE} 0 ${GIT_INDEX} GIT_VERSION)
		if(NOT ${GIT_INDEX} EQUAL -1)
			math(EXPR GIT_INDEX_NEXT "${GIT_INDEX} + 1")
			string(SUBSTRING ${GIT_DESCRIBE} ${GIT_INDEX_NEXT} -1 GIT_DESCRIBE_SUB)
		else()
			set(GIT_DESCRIBE_SUB "")
		endif()
		#Remove 'v' or 'V' prefix
		string(FIND ${GIT_VERSION} "v" GIT_INDEX)
		if(${GIT_INDEX} EQUAL -1)
			string(FIND ${GIT_VERSION} "V" GIT_INDEX)
		endif()
		if(NOT ${GIT_INDEX} EQUAL -1)
			math(EXPR GIT_INDEX_NEXT "${GIT_INDEX} + 1") 
			string(SUBSTRING ${GIT_VERSION} ${GIT_INDEX_NEXT} -1 GIT_VERSION)
		endif()
	else()
		#Default version if not found
		set(GIT_VERSION "0.0.0")
	endif()
	#Major
	string(FIND ${GIT_VERSION} "." GIT_INDEX)
	string(SUBSTRING ${GIT_VERSION} 0 ${GIT_INDEX} GIT_VERSION_MAJOR)
	if(NOT ${GIT_INDEX} EQUAL -1)
		math(EXPR GIT_INDEX_NEXT "${GIT_INDEX} + 1")
		string(SUBSTRING ${GIT_VERSION} ${GIT_INDEX_NEXT} -1 GIT_VERSION_SUB)
	else()
		set(GIT_VERSION_SUB "")
	endif()
	#Minor
	string(FIND ${GIT_VERSION_SUB} "." GIT_INDEX)
	string(SUBSTRING ${GIT_VERSION_SUB} 0 ${GIT_INDEX} GIT_VERSION_MINOR)
	if(NOT ${GIT_INDEX} EQUAL -1)
		math(EXPR GIT_INDEX_NEXT "${GIT_INDEX} + 1")
		string(SUBSTRING ${GIT_VERSION_SUB} ${GIT_INDEX_NEXT} -1 GIT_VERSION_SUB)
	else()
		set(GIT_VERSION_SUB "")
	endif()
	#Patch
	if(NOT ${GIT_VERSION_SUB} STREQUAL "")
		set(GIT_VERSION_PATCH ${GIT_VERSION_SUB})
	else()
		set(GIT_VERSION_PATCH "")
	endif()
	set(GIT_VERSION_SUB "")
	
	#Get Git additional commits
	if(NOT ${GIT_DESCRIBE_SUB} STREQUAL "")
		string(FIND ${GIT_DESCRIBE_SUB} "-" GIT_INDEX)
		string(SUBSTRING ${GIT_DESCRIBE_SUB} 0 ${GIT_INDEX} GIT_ADDITIONAL_COMMITS)
		if(NOT ${GIT_INDEX} EQUAL -1)
			math(EXPR GIT_INDEX_NEXT "${GIT_INDEX} + 1")
			string(SUBSTRING ${GIT_DESCRIBE_SUB} ${GIT_INDEX_NEXT} -1 GIT_DESCRIBE_SUB)
		else()
			set(GIT_DESCRIBE_SUB "")
		endif()
	endif()

	#Get Git commit
	if(NOT ${GIT_DESCRIBE_SUB} STREQUAL "")
		string(FIND ${GIT_DESCRIBE_SUB} "-" GIT_INDEX)
		string(SUBSTRING ${GIT_DESCRIBE_SUB} 0 ${GIT_INDEX} GIT_COMMIT)
		if(NOT ${GIT_INDEX} EQUAL -1)
			math(EXPR GIT_INDEX_NEXT "${GIT_INDEX} + 1")
			string(SUBSTRING ${GIT_DESCRIBE_SUB} ${GIT_INDEX_NEXT} -1 GIT_DESCRIBE_SUB)
		else()
			set(GIT_DESCRIBE_SUB "")
		endif()
		string(FIND ${GIT_COMMIT} "g" GIT_INDEX)
		if(NOT ${GIT_INDEX} EQUAL -1)
			math(EXPR GIT_INDEX_NEXT "${GIT_INDEX} + 1") 
			string(SUBSTRING ${GIT_COMMIT} ${GIT_INDEX_NEXT} -1 GIT_COMMIT)
		endif()
	endif()

	#Get Git is dirty
	if(NOT ${GIT_DESCRIBE_SUB} STREQUAL "")
		set(GIT_IS_DIRTY true)
	else()
		set(GIT_IS_DIRTY false)
	endif()
	set(GIT_DESCRIBE_SUB "")
		
	execute_process(
		COMMAND ${GIT_EXECUTABLE} config --file .gitmodules --get-regexp path
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		OUTPUT_VARIABLE GIT_SUBMODULE_PATH_PAIRS
	)
	if(NOT "${GIT_SUBMODULE_PATH_PAIRS}" STREQUAL "")
		string(STRIP ${GIT_SUBMODULE_PATH_PAIRS} GIT_SUBMODULE_PATH_PAIRS)
		string(REGEX REPLACE "\r?\n|\r" ";" GIT_SUBMODULE_PATH_PAIRS ${GIT_SUBMODULE_PATH_PAIRS})
		set(GIT_SUBMODULE_PATHS ${GIT_SUBMODULE_PATH_PAIRS})
		set(GIT_SUBMODULE_NAMES ${GIT_SUBMODULE_PATH_PAIRS})
		list(TRANSFORM GIT_SUBMODULE_PATHS REPLACE "submodule\..+\.path " "")
		#list(TRANSFORM GIT_SUBMODULE_NAMES REPLACE "submodule\.|\.path .+" "")
	endif()
	set(${proj_name}_GIT_VERSION ${GIT_VERSION} PARENT_SCOPE)
	set(${proj_name}_GIT_VERSION_MAJOR ${GIT_VERSION_MAJOR} PARENT_SCOPE)
	set(${proj_name}_GIT_VERSION_MINOR ${GIT_VERSION_MINOR} PARENT_SCOPE)
	set(${proj_name}_GIT_VERSION_PATCH ${GIT_VERSION_PATCH} PARENT_SCOPE)
	set(${proj_name}_GIT_IS_DIRTY ${GIT_IS_DIRTY} PARENT_SCOPE)
	set(${proj_name}_GIT_COMMIT ${GIT_COMMIT} PARENT_SCOPE)
	set(${proj_name}_GIT_ADDITIONAL_COMMITS ${GIT_ADDITIONAL_COMMITS} PARENT_SCOPE)
	set(${proj_name}_GIT_SUBMODULES_STORED ${GIT_SUBMODULE_PATHS} PARENT_SCOPE)
	#set(${proj_name}_GIT_SUBMODULE_NAMES ${GIT_SUBMODULE_NAMES} PARENT_SCOPE)
endfunction()
function(git_update_submodules)
	set(GIT_SUBMOD_RESULT "1")
	if(GIT_SUBMODULE)
		message(STATUS "Submodule update")
		execute_process(COMMAND ${GIT_EXECUTABLE} submodule foreach -q --recursive "\"${GIT_EXECUTABLE}\" switch $(\"${GIT_EXECUTABLE}\" config -f $toplevel/.gitmodules submodule.$name.branch || echo master)" 
	 									WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 									RESULT_VARIABLE GIT_SUBMOD_RESULT)
		if(NOT GIT_SUBMOD_RESULT EQUAL "0")
	 		message(FATAL_ERROR "git submodule update --init failed with ${GIT_SUBMOD_RESULT}")
		endif()
	endif()
	if(NOT GIT_SUBMOD_RESULT EQUAL "0")
		message(FATAL_ERROR "The submodules were not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
	endif()
endfunction()
function(git_update_submodule submodule_dir)
	message("Updating submodule ${submodule_dir} in ${PROJECT_NAME}")
	execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse @{0}
	 				WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${submodule_dir}"
	 				RESULT_VARIABLE COMMAND_RESULT)
	set(SUBMODULE_CURRENT_COMMIT ${COMMAND_RESULT})
	if(GIT_FETCH_SUBMODULES)
		execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --remote -- "${submodule_dir}"
						WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 					RESULT_VARIABLE COMMAND_RESULT)
		if(NOT COMMAND_RESULT EQUAL "0")
	 		message(FATAL_ERROR  "Unable to update submodule ${submodule_dir}.")
		endif()
	endif()
	execute_process(COMMAND ${GIT_EXECUTABLE} config -f .gitmodules submodule.${submodule_dir}.branch
	 				WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 				RESULT_VARIABLE COMMAND_RESULT
					OUTPUT_VARIABLE COMMAND_OUTPUT)
	if("${COMMAND_OUTPUT}" STREQUAL "")
		set(COMMAND_OUTPUT "master")
	endif()
	string(STRIP "${COMMAND_OUTPUT}" COMMAND_OUTPUT)
	execute_process(COMMAND ${GIT_EXECUTABLE} switch ${COMMAND_OUTPUT}
	 				WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${submodule_dir}"
	 				RESULT_VARIABLE COMMAND_RESULT)
	if(NOT COMMAND_RESULT EQUAL "0")
	 	message(FATAL_ERROR  "Unable to update submodule ${submodule_dir}.")
	endif()
	execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse @{0}
	 				WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${submodule_dir}"
	 				RESULT_VARIABLE COMMAND_RESULT)
	set(SUBMODULE_NEW_COMMIT ${COMMAND_RESULT})

	if("${SUBMODULE_CURRENT_COMMIT}" STREQUAL "${SUBMODULE_NEW_COMMIT}")
		message("Submodule ${submodule_dir} in ${PROJECT_NAME} up to date.")
	else()
		message("Submodule ${submodule_dir} in ${PROJECT_NAME} switched from ${SUBMODULE_CURRENT_COMMIT} to ${SUBMODULE_NEW_COMMIT}")
	endif()
endfunction()
macro(git_add_submodule directory remote)
	if(NOT ${directory} IN_LIST ${PROJECT_NAME}_GIT_SUBMODULE_DIRS)
		execute_process(COMMAND ${GIT_EXECUTABLE} submodule add --force "${remote}" "${directory}"
						WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 					RESULT_VARIABLE COMMAND_RESULT)
		if(NOT COMMAND_RESULT EQUAL "0")
			message(FATAL_ERROR "Unable to add submodule ${directory}.")
		endif()
		execute_process(COMMAND ${GIT_EXECUTABLE} submodule init "${directory}"
						WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 					RESULT_VARIABLE COMMAND_RESULT)
		if(NOT COMMAND_RESULT EQUAL "0")
			message(FATAL_ERROR "Unable to initialize submodule ${directory}.")
		endif()
	endif()
	if(ARGC EQUAL "3")
		execute_process(COMMAND ${GIT_EXECUTABLE} submodule set-branch --branch "${ARGV2}" -- "${directory}"
						WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 					RESULT_VARIABLE COMMAND_RESULT)
		if(NOT COMMAND_RESULT EQUAL "0")
			message(FATAL_ERROR "Unable to select branch ${ARGV2} for submodule ${directory}.")
		endif()
	else()
		execute_process(COMMAND ${GIT_EXECUTABLE} submodule set-branch --default -- "${directory}"
						WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	 					RESULT_VARIABLE COMMAND_RESULT)
		if(NOT COMMAND_RESULT EQUAL "0")
			message(FATAL_ERROR "Unable to select default branch for submodule ${directory}.")
		endif()
	endif()
	git_update_submodule("${directory}")
	list(APPEND ${PROJECT_NAME}_GIT_SUBMODULES "${directory}")
endmacro()