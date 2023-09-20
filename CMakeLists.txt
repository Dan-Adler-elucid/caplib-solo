cmake_minimum_required( VERSION 3.24 )

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

add_subdirectory( caplib )
add_subdirectory( disp )
