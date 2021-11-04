function(target_set_dir_src TARGET_NAME DIR)
    if(IS_ABSOLUTE "${DIR}")
        set(${TARGET_NAME}_DIR_SRC "${DIR}" PARENT_SCOPE)
    else()
        set(${TARGET_NAME}_DIR_SRC "${CMAKE_CURRENT_SOURCE_DIR}/${DIR}" PARENT_SCOPE)
    endif()
endfunction()
function(target_set_dir_hdr_private TARGET_NAME DIR)
    if(IS_ABSOLUTE "${DIR}")
        set(${TARGET_NAME}_DIR_HDR_PRIVATE "${DIR}" PARENT_SCOPE)
    else()
        set(${TARGET_NAME}_DIR_HDR_PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/${DIR}" PARENT_SCOPE)
    endif()
endfunction()
function(target_set_dir_hdr_interface TARGET_NAME DIR)
    if(IS_ABSOLUTE "${DIR}")
        set(${TARGET_NAME}_DIR_HDR_INTERFACE "${DIR}" PARENT_SCOPE)
    else()
        set(${TARGET_NAME}_DIR_HDR_INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/${DIR}" PARENT_SCOPE)
    endif()
endfunction()
function(target_set_dir_hdr_public TARGET_NAME DIR)
    if(IS_ABSOLUTE "${DIR}")
        set(${TARGET_NAME}_DIR_HDR_PUBLIC "${DIR}" PARENT_SCOPE)
    else()
        set(${TARGET_NAME}_DIR_HDR_PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/${DIR}" PARENT_SCOPE)
    endif()
endfunction()
macro(target_set_dir_hdr TARGET_NAME DIR)
    target_set_dir_hdr_private(${TARGET_NAME} ${DIR})
    target_set_dir_hdr_interface(${TARGET_NAME} ${DIR})
    target_set_dir_hdr_public(${TARGET_NAME} ${DIR})
endmacro()
macro(target_set_dir TARGET_NAME DIR)
    target_set_dir_src(${TARGET_NAME} ${DIR})
    target_set_dir_hdr(${TARGET_NAME} ${DIR})
endmacro()

macro(_target_setup_lib TARGET_NAME)
    set_target_properties(${TARGET_NAME} PROPERTIES
        FOLDER "${${PROJECT_NAME}_NAMESPACE}/Libraries"
    )
endmacro()
macro(_target_setup_exe TARGET_NAME)
    set_target_properties(${TARGET_NAME} PROPERTIES
        FOLDER "${${PROJECT_NAME}_NAMESPACE}/Executables"
    )
endmacro()
macro(_target_general_setup TARGET_NAME)
    target_set_dir(${TARGET_NAME} "${CMAKE_CURRENT_SOURCE_DIR}")

    get_target_property(${TARGET_NAME}_TYPE ${TARGET_NAME} TYPE)
    set(${TARGET_NAME}_TYPE "${${TARGET_NAME}_TYPE}")
    if(NOT "${${TARGET_NAME}_TYPE}" STREQUAL "INTERFACE_LIBRARY")
        set_target_properties(${TARGET_NAME} PROPERTIES
            CXX_STANDARD 20
            VERSION ${PROJECT_VERSION}
            LINKER_LANGUAGE CXX
        )
        if("${${TARGET_NAME}_TYPE}" STREQUAL "STATIC_LIBRARY" OR "${${TARGET_NAME}_TYPE}" STREQUAL "SHARED_LIBRARY")
            _target_setup_lib(${TARGET_NAME})
        elseif("${${TARGET_NAME}_TYPE}" STREQUAL "EXECUTABLE")
            _target_setup_exe(${TARGET_NAME})
        endif()
    endif()
    set(${TARGET_NAME}_VERSION ${PROJECT_VERSION} CACHE INTERNAL "Target version.")
endmacro()
macro(target_create_gui TARGET_NAME)
	add_executable(${TARGET_NAME} WIN32)
	if("${${PROJECT_NAME}_NAMESPACE}" STREQUAL "")
		add_executable("${PROJECT_NAME}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
    else()
        add_executable("${${PROJECT_NAME}_NAMESPACE}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
	endif()
    _target_general_setup(${TARGET_NAME})
endmacro()
macro(target_create_exe TARGET_NAME)
	add_executable(${TARGET_NAME})
	if("${${PROJECT_NAME}_NAMESPACE}" STREQUAL "")
		add_executable("${PROJECT_NAME}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
    else()
        add_executable("${${PROJECT_NAME}_NAMESPACE}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
	endif()
    _target_general_setup(${TARGET_NAME})
endmacro()
macro(target_create_lib TARGET_NAME)
	if(${ARGC} GREATER 1)
		add_library(${TARGET_NAME} ${ARGV1})
	else()
		add_library(${TARGET_NAME})
	endif()
	if("${${PROJECT_NAME}_NAMESPACE}" STREQUAL "")
		add_library("${PROJECT_NAME}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
    else()
        add_library("${${PROJECT_NAME}_NAMESPACE}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
	endif()
    _target_general_setup(${TARGET_NAME})
endmacro()
function(target_link TARGET_NAME)
    set_target_properties(${TARGET_NAME} PROPERTIES
        PUBLIC_HEADER "${${TARGET_NAME}_HDR_INTERFACE};${${TARGET_NAME}_HDR_PUBLIC}"
    )
    if(NOT "${${TARGET_NAME}_TYPE}" STREQUAL "INTERFACE_LIBRARY")
        target_include_directories(
            ${TARGET_NAME}
            PRIVATE
                "${${TARGET_NAME}_DIR_SRC}"
                "${${TARGET_NAME}_DIR_HDR_PRIVATE}"
            PUBLIC
                "$<BUILD_INTERFACE:${${TARGET_NAME}_DIR_HDR_PUBLIC}>"
        )
        target_sources(
            ${TARGET_NAME}
            PRIVATE
                "${${TARGET_NAME}_SRC}"
                "${${TARGET_NAME}_HDR_PRIVATE}"
            PUBLIC
                "$<BUILD_INTERFACE:${${TARGET_NAME}_HDR_PUBLIC}>"
        )
        target_link_libraries(
            ${TARGET_NAME}
            PRIVATE
                "${${TARGET_NAME}_DEP_PRIVATE}"
            PUBLIC
                "$<BUILD_INTERFACE:${${TARGET_NAME}_DEP_PUBLIC}>"
        )
    else()
        target_include_directories(
            ${TARGET_NAME}
            INTERFACE
                "$<BUILD_INTERFACE:${${TARGET_NAME}_DIR_HDR_PUBLIC}>"
        )
        target_sources(
            ${TARGET_NAME}
            INTERFACE
                "$<BUILD_INTERFACE:${${TARGET_NAME}_HDR_PUBLIC}>"
        )
        target_link_libraries(
            ${TARGET_NAME}
            INTERFACE
                "$<BUILD_INTERFACE:${${TARGET_NAME}_DEP_PUBLIC}>"
        )
    endif()
    target_include_directories(
        ${TARGET_NAME}
        INTERFACE
            "$<BUILD_INTERFACE:${${TARGET_NAME}_DIR_HDR_INTERFACE}>"
    )
    target_sources(
        ${TARGET_NAME}
        INTERFACE
            "$<BUILD_INTERFACE:${${TARGET_NAME}_HDR_INTERFACE}>"
    )
    target_link_libraries(
        ${TARGET_NAME}
        INTERFACE
            "$<BUILD_INTERFACE:${${TARGET_NAME}_DEP_INTERFACE}>"
    )
    list(APPEND ${PROJECT_NAME}_INSTALL_TARGETS ${TARGET_NAME})
    set(${PROJECT_NAME}_INSTALL_TARGETS ${${PROJECT_NAME}_INSTALL_TARGETS} PARENT_SCOPE)
    list(APPEND ${PROJECT_NAME}_INSTALL_FILES "${${TARGET_NAME}_HDR_INTERFACE}")
    list(APPEND ${PROJECT_NAME}_INSTALL_FILES "${${TARGET_NAME}_HDR_PUBLIC}")
    set(${PROJECT_NAME}_INSTALL_FILES ${${PROJECT_NAME}_INSTALL_FILES} PARENT_SCOPE)

    get_target_property(OUT_INCLUDE_DIRECTORIES ${TARGET_NAME} INCLUDE_DIRECTORIES)
    get_target_property(OUT_INTERFACE_INCLUDE_DIRECTORIES ${TARGET_NAME} INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(OUT_SOURCES ${TARGET_NAME} SOURCES)
    get_target_property(OUT_INTERFACE_SOURCES ${TARGET_NAME} INTERFACE_SOURCES)
    get_target_property(OUT_LINK_LIBRARIES ${TARGET_NAME} LINK_LIBRARIES)
    get_target_property(OUT_INTERFACE_LINK_LIBRARIES ${TARGET_NAME} INTERFACE_LINK_LIBRARIES)
endfunction()
function(check_target TARGET_NAME)
    if(NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "Target ${TARGET_NAME} does not exist.")
    endif()
    get_target_property(ALIASED_NAME ${TARGET_NAME} ALIASED_TARGET)
    if(NOT ALIASED_NAME)
        set(ALIASED_NAME ${TARGET_NAME})
    endif()
    set(TARGET_VERSION ${${ALIASED_NAME}_VERSION})
    if(${ARGC} GREATER 1)
        if("${TARGET_VERSION}" VERSION_LESS "${ARGV1}")
            message(FATAL_ERROR "Target ${ALIASED_NAME} (${TARGET_VERSION}) does not meet the minimum version requirement (${ARGV1}).")
        endif()
    endif()
    if(${ARGC} GREATER 2)
        if("${TARGET_VERSION}" VERSION_GREATER "${ARGV2}")
            message(FATAL_ERROR "Target ${ALIASED_NAME} (${TARGET_VERSION}) does not meet the maximum version requirement (${ARGV2}).")
        endif()
    endif()
endfunction()
function(target_append_dep_private TARGET_NAME DEP_NAME)
    check_target(${DEP_NAME} ${ARGN})
    list(APPEND ${TARGET_NAME}_DEP_PRIVATE ${DEP_NAME})
    set(${TARGET_NAME}_DEP_PRIVATE ${${TARGET_NAME}_DEP_PRIVATE} PARENT_SCOPE)
endfunction()
function(target_append_dep_interface TARGET_NAME DEP_NAME)
    check_target(${DEP_NAME} ${ARGN})
    list(APPEND ${TARGET_NAME}_DEP_INTERFACE ${DEP_NAME})
    set(${TARGET_NAME}_DEP_INTERFACE ${${TARGET_NAME}_DEP_INTERFACE} PARENT_SCOPE)
endfunction()
function(target_append_dep_public TARGET_NAME DEP_NAME)
    check_target(${DEP_NAME} ${ARGN})
    list(APPEND ${TARGET_NAME}_DEP_PUBLIC ${DEP_NAME})
    set(${TARGET_NAME}_DEP_PUBLIC ${${TARGET_NAME}_DEP_PUBLIC} PARENT_SCOPE)
endfunction()
function(target_append_dep TARGET_NAME DEP_NAME)
    target_append_dep_private(${TARGET_NAME} ${DEP_NAME})
    set(${TARGET_NAME}_DEP_PRIVATE ${${TARGET_NAME}_DEP_PRIVATE} PARENT_SCOPE)
endfunction()
function(target_append_src TARGET_NAME)
    list(LENGTH ARGN ARGN_LENGTH)
    if(${ARGN_LENGTH} GREATER 0)
        list(TRANSFORM ARGN PREPEND "${${TARGET_NAME}_DIR_SRC}/")
        list(APPEND ${TARGET_NAME}_SRC ${ARGN})
        set(${TARGET_NAME}_SRC ${${TARGET_NAME}_SRC} PARENT_SCOPE)
    endif()
endfunction()
function(target_append_hdr_private TARGET_NAME)
    list(LENGTH ARGN ARGN_LENGTH)
    if(${ARGN_LENGTH} GREATER 0)
        list(TRANSFORM ARGN PREPEND "${${TARGET_NAME}_DIR_HDR_PRIVATE}/")
        list(APPEND ${TARGET_NAME}_HDR_PRIVATE ${ARGN})
        set(${TARGET_NAME}_HDR_PRIVATE ${${TARGET_NAME}_HDR_PRIVATE} PARENT_SCOPE)
    endif()
endfunction()
function(target_append_hdr_interface TARGET_NAME)
    list(LENGTH ARGN ARGN_LENGTH)
    if(${ARGN_LENGTH} GREATER 0)
        list(TRANSFORM ARGN PREPEND "${${TARGET_NAME}_DIR_HDR_INTERFACE}/")
        list(APPEND ${TARGET_NAME}_HDR_INTERFACE ${ARGN})
        set(${TARGET_NAME}_HDR_INTERFACE ${${TARGET_NAME}_HDR_INTERFACE} PARENT_SCOPE)
    endif()
endfunction()
function(target_append_hdr_public TARGET_NAME)
    list(LENGTH ARGN ARGN_LENGTH)
    if(${ARGN_LENGTH} GREATER 0)
        list(TRANSFORM ARGN PREPEND "${${TARGET_NAME}_DIR_HDR_PUBLIC}/")
        list(APPEND ${TARGET_NAME}_HDR_PUBLIC ${ARGN})
        set(${TARGET_NAME}_HDR_PUBLIC ${${TARGET_NAME}_HDR_PUBLIC} PARENT_SCOPE)
    endif()
endfunction()
function(target_append_hdr TARGET_NAME)
    list(LENGTH ARGN ARGN_LENGTH)
    if(${ARGN_LENGTH} GREATER 0)
        target_append_hdr_private(${TARGET_NAME} ${ARGN})
        set(${TARGET_NAME}_HDR_PRIVATE ${${TARGET_NAME}_HDR_PRIVATE} PARENT_SCOPE)
    endif()
endfunction()