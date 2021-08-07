option(GIT_SUBMODULE "Check submodules during build" ON)
# Git
find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git")
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

	# endif()
	 # Update Git submodules
	 set(GIT_SUBMOD_RESULT "1")
     if(GIT_SUBMODULE)
	 		message(STATUS "Submodule update")
	 		execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
	 										WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	 										RESULT_VARIABLE GIT_SUBMOD_RESULT)
	 		if(NOT GIT_SUBMOD_RESULT EQUAL "0")
	 			message(FATAL_ERROR "git submodule update --init failed with ${GIT_SUBMOD_RESULT}, please checkout submodules")
	 		endif()
     endif()
	 if(NOT GIT_SUBMOD_RESULT EQUAL "0")
	 	message(FATAL_ERROR "The submodules were not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
	 endif()
else()
	message(FATAL_ERROR "Git not found or project is not initialized.")
endif()