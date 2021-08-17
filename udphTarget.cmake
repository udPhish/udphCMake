function(target_set_dir TARGET_NAME DIR)
    set(${TARGET_NAME}_DIR_SRC "${DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_PRIVATE "${DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_INTERFACE "${DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_PUBLIC "${DIR}" PARENT_SCOPE)
endfunction()
function(target_set_dir_src TARGET_NAME DIR)
    set(${TARGET_NAME}_DIR_SRC "${DIR}" PARENT_SCOPE)
endfunction()
function(target_set_dir_hdr TARGET_NAME DIR)
    set(${TARGET_NAME}_DIR_HDR_PRIVATE "${DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_INTERFACE "${DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_PUBLIC "${DIR}" PARENT_SCOPE)
endfunction()
function(target_set_dir_hdr_private TARGET_NAME DIR)
    set(${TARGET_NAME}_DIR_HDR_PRIVATE "${DIR}" PARENT_SCOPE)
endfunction()
function(target_set_dir_hdr_interface TARGET_NAME DIR)
    set(${TARGET_NAME}_DIR_HDR_INTERFACE "${DIR}" PARENT_SCOPE)
endfunction()
function(target_set_dir_hdr_public TARGET_NAME DIR)
    set(${TARGET_NAME}_DIR_HDR_PUBLIC "${DIR}" PARENT_SCOPE)
endfunction()
macro(target_general_setup TARGET_NAME)
    set(${TARGET_NAME}_DIR_SRC "${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
    set(${TARGET_NAME}_DIR_HDR_PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
    get_target_property(${TARGET_NAME}_TYPE ${TARGET_NAME} TYPE)
    set(${TARGET_NAME}_TYPE "${${TARGET_NAME}_TYPE}" PARENT_SCOPE)
    if(NOT "${${TARGET_NAME}_TYPE}" STREQUAL "INTERFACE_LIBRARY")
        set_target_properties(${TARGET_NAME} PROPERTIES
            CXX_STANDARD 20
            VERSION ${PROJECT_VERSION}
            LINKER_LANGUAGE CXX
        )
    endif()
    
	set(${TARGET_NAME}_VERSION ${${PROJECT_NAME}_VERSION} PARENT_SCOPE)
	set(${TARGET_NAME}_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR} PARENT_SCOPE)
	set(${TARGET_NAME}_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR} PARENT_SCOPE)
	set(${TARGET_NAME}_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH} PARENT_SCOPE)
endmacro()
function(target_create_exe TARGET_NAME)
	add_executable(${TARGET_NAME})
	if("${${PROJECT_NAME}_NAMESPACE}" STREQUAL "")
		add_executable("${PROJECT_NAME}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
    else()
        add_executable("${${PROJECT_NAME}_NAMESPACE}::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
	endif()
    target_general_setup(${TARGET_NAME})
endfunction()
function(target_create_lib TARGET_NAME)
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
    target_general_setup(${TARGET_NAME})
endfunction()
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
                "${${TARGET_NAME}_DIR_HDR_PUBLIC}"
        )
        target_sources(
            ${TARGET_NAME}
            PRIVATE
                "${${TARGET_NAME}_SRC}"
                "${${TARGET_NAME}_HDR_PRIVATE}"
                "${${TARGET_NAME}_HDR_PUBLIC}"
        )
        target_link_libraries(
            ${TARGET_NAME}
            PRIVATE
                "${${TARGET_NAME}_DEP_PRIVATE}"
                "${${TARGET_NAME}_DEP_PUBLIC}"
        )
    endif()
    target_include_directories(
        ${TARGET_NAME}
        INTERFACE
            "$<BUILD_INTERFACE:${${TARGET_NAME}_DIR_HDR_INTERFACE};${${TARGET_NAME}_DIR_HDR_PUBLIC}>"
    )
    target_sources(
        ${TARGET_NAME}
        INTERFACE
            "$<BUILD_INTERFACE:${${TARGET_NAME}_HDR_INTERFACE};${${TARGET_NAME}_HDR_PUBLIC}>"
    )
    target_link_libraries(
        ${TARGET_NAME}
        INTERFACE
            "${${TARGET_NAME}_DEP_INTERFACE}"
            "${${TARGET_NAME}_DEP_PUBLIC}"
    )
endfunction()
function(check_target TARGET_NAME)
    if(NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "Target ${TARGET_NAME} does not exist.")
    endif()
    if(${ARGC} > 1)
        if("${DEP_NAME}_VERSION" VERSION_LESS "${ARGV1}")
            message(FATAL_ERROR "Target ${TARGET_NAME} (${${TARGET_NAME}_VERSION}) does not meet the minimum version requirement (${ARGV1}).")
        endif()
    endif()
    if(${ARGC} > 2)
        if("${DEP_NAME}_VERSION" VERSION_GREATER "${ARGV2}")
            message(FATAL_ERROR "Target ${TARGET_NAME} (${${TARGET_NAME}_VERSION}) does not meet the maximum version requirement (${ARGV2}).")
        endif()
    endif()
endfunction()
function(target_append_dep_private TARGET_NAME DEP_NAME)
    check_target(${TARGET_NAME} ${ARGN})
    list(APPEND ${TARGET_NAME}_DEP_PRIVATE ${ARGN})
    set(${TARGET_NAME}_DEP_PRIVATE ${${TARGET_NAME}_DEP_PRIVATE} PARENT_SCOPE)
endfunction()
function(target_append_dep_interface TARGET_NAME)
    check_target(${TARGET_NAME} ${ARGN})
    list(APPEND ${TARGET_NAME}_DEP_INTERFACE ${ARGN})
    set(${TARGET_NAME}_DEP_INTERFACE ${${TARGET_NAME}_DEP_INTERFACE} PARENT_SCOPE)
endfunction()
function(target_append_dep_public TARGET_NAME)
    check_target(${TARGET_NAME} ${ARGN})
    list(APPEND ${TARGET_NAME}_DEP_PUBLIC ${ARGN})
    set(${TARGET_NAME}_DEP_PUBLIC ${${TARGET_NAME}_DEP_PUBLIC} PARENT_SCOPE)
endfunction()
function(target_append_dep TARGET_NAME)
    target_append_dep_public(${DEP_NAME} ${ARGN})
    set(${TARGET_NAME}_DEP_PUBLIC ${${TARGET_NAME}_DEP_PUBLIC} PARENT_SCOPE)
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
        target_append_hdr_public(${TARGET_NAME} ${ARGN})
        set(${TARGET_NAME}_HDR_PUBLIC ${${TARGET_NAME}_HDR_PUBLIC} PARENT_SCOPE)
    endif()
endfunction()
function(target_package TARGET_NAME)
    set(${TARGET_NAME}_EXPORT ${${PROJECT_NAME}_GENERATED_HEADER_DIR}/${TARGET_NAME}_EXPORT.h)
    set(${TARGET_NAME}_EXPORT ${${TARGET_NAME}_EXPORT} PARENT_SCOPE)
    # Generate export header
    if(${${TARGET_NAME}_TYPE} STREQUAL "STATIC_LIBRARY" OR ${${TARGET_NAME}_TYPE} STREQUAL "SHARED_LIBRARY" OR ${${TARGET_NAME}_TYPE} STREQUAL "MODULE_LIBRARY")
        generate_export_header(${TARGET_NAME} EXPORT_FILE_NAME ${${TARGET_NAME}_EXPORT})
    endif()
    # Include generated directories
    if(${${TARGET_NAME}_TYPE} STREQUAL "INTERFACE_LIBRARY")
        target_include_directories(
        ${TARGET_NAME}
        INTERFACE
            $<BUILD_INTERFACE:${${PROJECT_NAME}_GENERATED_HEADER_DIR}>
        )
    else()
        target_include_directories(
        ${TARGET_NAME}
        PRIVATE
            ${${PROJECT_NAME}_GENERATED_HEADER_DIR}
        INTERFACE
            $<BUILD_INTERFACE:${${PROJECT_NAME}_GENERATED_HEADER_DIR}>
        )
    endif()
    # Configure package files
    write_basic_package_version_file(
        "${${PROJECT_NAME}_VERSION_CONFIG_FILE}"
        COMPATIBILITY
            SameMajorVersion
    )
    configure_package_config_file(
        "${UDPH_CMAKE_DIR}/udphConfig.cmake.in"
        ${${PROJECT_NAME}_CONFIG_FILE}
        INSTALL_DESTINATION
            "${${PROJECT_NAME}_CONFIG_INSTALL_DIR}"
    )

    #########
    # INSTALL
    #########
    # Target
    install(
        TARGETS ${TARGET_NAME}
        EXPORT ${${PROJECT_NAME}_TARGETS_FILE}
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    )
    # Includes
    install(
        FILES "${${TARGET_NAME}_HDR_INTERFACE};${${TARGET_NAME}_HDR_PUBLIC}"
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}
    )
    # Targets export
    install(
        FILES ${${TARGET_NAME}_EXPORT}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${${PROJECT_NAME}_NAMESPACE}/${PROJECT_NAME}
    )
    # Headers export
    install(
        EXPORT ${${PROJECT_NAME}_TARGETS_FILE}
        NAMESPACE ${${PROJECT_NAME}_NAMESPACE}
        DESTINATION ${${PROJECT_NAME}_CONFIG_INSTALL_DIR}
    )
    # Package files
    install(
        FILES ${${PROJECT_NAME}_CONFIG_FILE} ${${PROJECT_NAME}_VERSION_CONFIG_FILE}
        DESTINATION ${${PROJECT_NAME}_CONFIG_INSTALL_DIR}
    )
    # Export build
    export(TARGETS ${TARGET_NAME} NAMESPACE ${${PROJECT_NAME}_NAMESPACE}:: APPEND FILE ${${PROJECT_NAME}_TARGETS_FILE})
    set(CMAKE_EXPORT_PACKAGE_REGISTRY ON)
    set(CMAKE_EXPORT_PACKAGE_REGISTRY ON PARENT_SCOPE)
    export(PACKAGE ${PROJECT_NAME})
endfunction()