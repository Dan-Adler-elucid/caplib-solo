cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
    cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( NRRDFileCreation VERSION 1.0.0 LANGUAGES C CXX )

set( ITK_DIR ${External_ITK_DIR} )
set( VTK_DIR ${External_VTK_DIR} )
set( IVAN_DIR ${External_IVANTK_DIR} )

find_package( ITK HINTS ${ITK_DIR} REQUIRED )
find_package( VTK HINTS ${VTK_DIR} REQUIRED )
find_package( IVAN HINTS ${IVAN_DIR} REQUIRED )

if( ITK_FOUND )
    include( ${ITK_USE_FILE} )
else()
    message( FATAL_ERROR "ITK was not found. Please set ITK_DIR." )
endif()

if( NOT VTK_FOUND )
    message( FATAL_ERROR "VTK was not found. Please set VTK_DIR." )
endif()

if( IVAN_FOUND )
    include( ${IVAN_USE_FILE} )
else()
    message( FATAL_ERROR "IVAN library not found. Please set IVAN_DIR." )
endif()

if( CMAKE_BUILD_TYPE STREQUAL "Release" )
    set( IVAN_LIBRARIES ivanCommon ivanITK )
elseif( CMAKE_BUILD_TYPE STREQUAL "Debug" )
    set( IVAN_LIBRARIES ivanCommond ivanITKd )
endif()


set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( CAPLIB_CPP_DIR ${COMMON_LIBS_DIR}/caplib/cpp )
set( NRRD_CPP_DIR ${COMMON_LIBS_DIR}/test/NRRDFileCreation )

add_executable( NRRDFileCreation )

target_sources( NRRDFileCreation PRIVATE
    ${NRRD_CPP_DIR}/NRRDFileCreation.cxx
)

target_link_directories( NRRDFileCreation PRIVATE
    ${External_DCMTK_LIB_DIR}
    ${IVAN_LIBRARY_DIRS}
)

target_include_directories( NRRDFileCreation PRIVATE
    ${CAPLIB_CPP_DIR}
    ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
)

target_include_directories( NRRDFileCreation SYSTEM PRIVATE
    ${ITK_INCLUDE_DIRS}
    ${VTK_INCLUDE_DIRS}
    ${IVAN_INCLUDE_DIRS}
)

target_link_libraries( NRRDFileCreation PRIVATE
    caplib
    ${ITK_LIBRARIES}
    ${VTK_LIBRARIES}
    ${DCMTK_LIBRARIES}
    ${IVAN_LIBRARIES}
)

target_compile_definitions( NRRDFileCreation PRIVATE
    ${EBV_COMPILE_DEFINITIONS}
    ${VTK_DEFINITIONS}
)

target_compile_options( caplib PRIVATE
    #   -Werror
    #   -Wall -Wextra -Wpointer-arith -Winit-self -Wunreachable-code
    #   -Wno-error=array-bounds
    #   -Wno-error=empty-body
    #   -Wno-error=maybe-uninitialized
    #   -Wno-error=stringop-overflow
    #   -Wshadow -g -ftrapv
    #   -Wconversion -Wsign-conversion
    #   -Wshadow
    -O3
)

set_target_properties( NRRDFileCreation PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
)
