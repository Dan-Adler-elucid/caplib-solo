cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
    cmake_policy( SET CMP0048 NEW )
endif( COMMAND cmake_policy )

project( caplib-solo VERSION 1.0.0 LANGUAGES C CXX )

if( NOT CAPLIB_SOURCE_DIR )
    set( CAPLIB_SOURCE_DIR . )
endif()

set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )

set( CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-undefined" )

# ITKVtkGlue in ITK 4.12.2 doesn't compile with VTK 9.0.3 (new module structure).
# This is a backported patch in ITK 4.12.2 to introduce the vtk_module_config,
# which has been removed in VTK 9 with a new module structure.

if( NOT COMMAND vtk_module_config )
    macro(vtk_module_config ns)
        foreach(arg ${ARGN})
            if(${arg} MATCHES "^[Vv][Tt][Kk]")
                string(REGEX REPLACE "^[Vv][Tt][Kk]" "" _arg ${arg})
            else()
                set(_arg ${arg})
            endif()

            set(${ns}_LIBRARIES ${${ns}_LIBRARIES} VTK::${_arg})
        endforeach()
    endmacro()
endif()

add_subdirectory( backendlib )
add_subdirectory( caplib )
add_subdirectory( commonlib )
add_subdirectory( configlib )
add_subdirectory( dicomlib )
add_subdirectory( SceneSerialization )
add_subdirectory( test )
