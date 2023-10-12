cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
    cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

SET(CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS 1)
SET(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS 1)

SET(CMAKE_C_RESPONSE_FILE_LINK_FLAG "@")
SET(CMAKE_CXX_RESPONSE_FILE_LINK_FLAG "@")

SET(CMAKE_NINJA_FORCE_RESPONSE_FILE 1 CACHE INTERNAL "")

project( SyntheticVessels VERSION 1.0.0 LANGUAGES C CXX )

set( ITK_DIR ${External_ITK_DIR} )
set( VTK_DIR ${External_VTK_DIR} )
set( IVAN_DIR ${External_IVANTK_DIR} )

find_package( VTK HINTS ${VTK_DIR} COMPONENTS REQUIRED
    CommonComputationalGeometry
    CommonCore
    CommonDataModel
    CommonMath
    CommonTransforms
    FiltersCore
    FiltersGeneral
    FiltersModeling
    FiltersSources
    InteractionStyle
    IOGeometry
    IOLegacy
    IOPLY
    IOXML
    RenderingContextOpenGL2
    RenderingCore
    RenderingFreeType
    RenderingGL2PSOpenGL2
    RenderingOpenGL2
)

find_package( ITK HINTS ${ITK_DIR} REQUIRED )
find_package( IVAN HINTS ${IVAN_DIR} REQUIRED )

if( NOT VTK_FOUND )
    message( FATAL_ERROR "VTK was not found. Please set VTK_DIR." )
endif()

if( ITK_FOUND )
    include( ${ITK_USE_FILE} )
else()
    message( FATAL_ERROR "ITK was not found. Please set ITK_DIR." )
endif()

if( IVAN_FOUND )
    include( ${IVAN_USE_FILE} )
else( IVAN_FOUND )
    message( FATAL_ERROR "IVAN library not found. Please set IVAN_DIR." )
endif()


set( TUBEGEN_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs/test/SyntheticVessels )

add_executable( tubegen )

target_sources( tubegen PRIVATE
    ${TUBEGEN_DIR}/tubegen.cpp
    ${TUBEGEN_DIR}/tubegen_details.cpp
    ${TUBEGEN_DIR}/tubegen_params.cpp
    ${TUBEGEN_DIR}/curves/Helix.cpp
    ${TUBEGEN_DIR}/curves/HelixParams.cpp
    ${TUBEGEN_DIR}/curves/Line.cpp
    ${TUBEGEN_DIR}/curves/LineParams.cpp
)

target_include_directories( tubegen SYSTEM PRIVATE
    ${TUBEGEN_DIR}
    ${TUBEGEN_DIR}/curves
    ${ITK_INCLUDE_DIRS}
    ${VTK_INCLUDE_DIRS}
    ${IVAN_INCLUDE_DIRS}
)

target_link_directories( tubegen PRIVATE
    ${IVAN_LIBRARY_DIRS}
)

target_link_libraries( tubegen PRIVATE
    ${ITK_LIBRARIES}
    ${VTK_LIBRARIES}
    ${IVAN_LIBRARIES}
)

target_compile_definitions( tubegen PRIVATE
    ${VTK_DEFINITIONS}
)

target_compile_options( tubegen PRIVATE
    -Werror
    -Wall -Wextra
    -Wpointer-arith
    -Winit-self
    -Wunreachable-code
    -Wno-error=array-bounds
    -Wno-error=empty-body
    -Wno-error=maybe-uninitialized
    -Wno-error=stringop-overflow
    -Wshadow
    -g -ftrapv
    -Wconversion
    -Wsign-conversion
    -Wshadow
    -O3
)

set_target_properties( tubegen PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
)

vtk_module_autoinit(
    TARGETS tubegen
    MODULES ${VTK_LIBRARIES}
)


add_executable( ExtrudePolyDataAlongLine MACOSX_BUNDLE
    ${TUBEGEN_DIR}/tube_extrude.cpp
    /home/danadler/dev/SplineDrivenImageSlicer/Filters/vtkFrenetSerretFrame.cxx
)

target_link_libraries( ExtrudePolyDataAlongLine PRIVATE
    ${VTK_LIBRARIES}
)

vtk_module_autoinit(
    TARGETS ExtrudePolyDataAlongLine
    MODULES ${VTK_LIBRARIES}
)


add_executable( FrenetSerretFrame MACOSX_BUNDLE
    ${TUBEGEN_DIR}/tubegen_fsframe.cpp
    /home/danadler/dev/SplineDrivenImageSlicer/Filters/vtkFrenetSerretFrame.cxx
)

target_link_libraries( FrenetSerretFrame PRIVATE
    ${VTK_LIBRARIES}
)

vtk_module_autoinit(
    TARGETS FrenetSerretFrame
    MODULES ${VTK_LIBRARIES}
)
