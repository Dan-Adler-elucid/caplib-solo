cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
    cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( SyntheticVessels VERSION 1.0.0 LANGUAGES C CXX )

set( ITK_DIR ${External_ITK_DIR} )
set( VTK_DIR ${External_VTK_DIR} )
set( IVAN_DIR ${External_IVANTK_DIR} )

find_package( VTK HINTS ${VTK_DIR} COMPONENTS REQUIRED
    CommonCore
    CommonDataModel
    FiltersCore
    FiltersSources
    InteractionStyle
    IOGeometry
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

set( TEST_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs/test )
set( TUBEGEN_DIR ${TEST_DIR}/SyntheticVessels )
set( CAPLIB_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs/caplib/cpp )
set( CONFIGLIB_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs/configlib )

set( TUBEGEN_SOURCES
    tubegen.cpp
    tubegen_details.cpp
    tubegen_params.cpp
    tubegen_render.cpp
    cpr_render.cpp
    CprInteractorStyle.cpp
    InteractorStyleSwitcherCallback.cpp
    curves/CurveHelper.cpp
    curves/Helix.cpp
    curves/HelixParams.cpp
    curves/Line.cpp
    curves/LineParams.cpp
    curves/PredefinedCurve.cpp
    curves/RandomSpline.cpp
    curves/RandomSplineParams.cpp
)

list( TRANSFORM TUBEGEN_SOURCES PREPEND "${TUBEGEN_DIR}/" )

set( TUBEGEN_CAPLIB_SOURCES
    ebLog.cxx
    ebvCPRFilter.cxx
    ebvCurvedPlanarReformationFilter.cxx
    ebvFrenetSerretRefFrame.cxx
    ebvPolyDataLSFitter.cxx
    ebvStretchedCprRefFrame.cxx
    ebvSystemInformation.cxx
    ebvTimeProbe.cxx
    ebvVesselCenterline.cxx
    ebvVesselTraverserBase.cxx
    ebvVesselTraverserStretched.cxx
    ebvVesselTraverserStraightened.cxx
)

list( TRANSFORM TUBEGEN_CAPLIB_SOURCES PREPEND "${CAPLIB_DIR}/" )

set( TUBEGEN_CONFIGLIB_SOURCES
    EVconfig.cxx
)

list( TRANSFORM TUBEGEN_CONFIGLIB_SOURCES PREPEND "${CONFIGLIB_DIR}/" )

add_executable( tubegen )

target_sources( tubegen PRIVATE
    ${TUBEGEN_SOURCES}
    ${TUBEGEN_CAPLIB_SOURCES}
    ${TUBEGEN_CONFIGLIB_SOURCES}
)

target_include_directories( tubegen PRIVATE
    ${TUBEGEN_DIR}
    ${TUBEGEN_DIR}/curves
    ${CAPLIB_DIR}
    ${CONFIGLIB_DIR}
    ${TEST_DIR}/CPRExamples
    ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h
)

target_include_directories( tubegen SYSTEM PRIVATE
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
    -Wno-sign-compare
    -Wshadow
    -g -ftrapv
#    -Wconversion
#    -Wsign-conversion
    -Wshadow
    -O3
)

set_target_properties( tubegen PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
)

vtk_module_autoinit(
    TARGETS tubegen
    MODULES ${VTK_LIBRARIES}
)
