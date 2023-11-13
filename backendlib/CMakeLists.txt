cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

project( backendlib VERSION 1.0.0 LANGUAGES CXX )

# Configuration types is used in IDEs
if( NOT CMAKE_CONFIGURATION_TYPES )
    set( CMAKE_CONFIGURATION_TYPES Release )
endif()

if( NOT CMAKE_BUILD_TYPE )
    set( CMAKE_BUILD_TYPE Release )
endif()

message( "Generated with CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}" )

set( CMAKE_AUTOMOC ON )

set( ITK_DIR ${External_ITK_DIR} )
set( VTK_DIR ${External_VTK_DIR} )
set( DCMTK_DIR ${External_DCMTK_DIR} )

find_package( ITK HINTS ${ITK_DIR} REQUIRED )
find_package( VTK HINTS ${VTK_DIR} REQUIRED )
find_package( DCMTK HINTS ${DCMTK_DIR} REQUIRED )

if( ITK_FOUND )
    include( ${ITK_USE_FILE} )
else()
    message( FATAL_ERROR "ITK was not found. Please set ITK_DIR." )
endif()

if( NOT VTK_FOUND )
    message( FATAL_ERROR "VTK was not found. Please set VTK_DIR." )
endif()

if( NOT DCMTK_FOUND )
    message( FATAL_ERROR "DCMTK was not found. Please set DCMTK_DIR." )
endif()

find_package( Qt5 COMPONENTS
    Core
    Network
    Widgets
    REQUIRED
)

set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( BACKENDLIB_CPP_DIR ${COMMON_LIBS_DIR}/backendlib )
set( CAPLIB_CPP_DIR ${COMMON_LIBS_DIR}/caplib/cpp )

set( BACKENDLIB_SOURCES
  EVCap.cpp
  EVLinkedViewers.cpp
  EVTargetDef.cpp
  EVTargetDefine.cpp
  EVTargetDefine_ANA.cpp
  EVTargetDefine_CLR.cpp
  EVTargetDefine_CRS.cpp
  EVTargetDefine_LMN.cpp
  EVTargetDefine_PDP.cpp
  EVTargetDefine_SEG.cpp
  EVTargetDefine_WAL.cpp
  EVVesselPipeline.cpp
  EVWorkItem.cpp
  processingParameters.cpp
  vtkEvRenderWindowImageGenerator.cpp
  vtkEvDataEncoder.cxx
)

list( TRANSFORM BACKENDLIB_SOURCES PREPEND ${BACKENDLIB_CPP_DIR}/ )

add_library( backendlib ${CAPLIB_LINKAGE} )

target_sources( backendlib PRIVATE
  ${BACKENDLIB_SOURCES}
)

target_link_libraries( backendlib PRIVATE
  caplib
  commonlib
  configlib
  ${ITK_LIBRARIES}
  ${VTK_LIBRARIES}
  ${DCMTK_LIBRARIES}
  ${Qt5Core_LIBRARIES}
  ${Qt5Network_LIBRARIES}
  ${Qt5Widgets_LIBRARIES}
)

target_link_directories( backendlib PRIVATE
  ${External_DCMTK_LIB_DIR}
)

target_include_directories( backendlib PRIVATE
  ${CAPLIB_CPP_DIR}
  ${COMMON_LIBS_DIR}/commonlib
  ${COMMON_LIBS_DIR}/configlib
  ${COMMON_LIBS_DIR}/dicomlib
  ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
)

# These are 'system' includes in order to ignore compiler warnings:
target_include_directories( backendlib SYSTEM PRIVATE
  ${ITK_INCLUDE_DIRS}
  ${VTK_INCLUDE_DIRS}
  ${DCMTK_INCLUDE_DIRS}
)

target_compile_definitions( backendlib PRIVATE
  ${EBV_COMPILE_DEFINITIONS}
  ${VTK_DEFINITIONS}
)

target_compile_options( backendlib PRIVATE
# -Werror
# -Wall -Wextra -Wpointer-arith -Winit-self -Wunreachable-code
  -Wno-error=array-bounds
  -Wno-error=empty-body
  -Wno-error=maybe-uninitialized
  -Wno-error=stringop-overflow
  -Wno-sign-compare
  -g -ftrapv
# -Wconversion -Wsign-conversion
  # -Wshadow
  -O3
)

#    -Wno-macro-redefined
#    -Wno-inconsistent-missing-override
#    -Wno-deprecated-declarations
#    -Wno-potentially-evaluated-expression
#    -Wno-constant-conversion

set_target_properties( backendlib PROPERTIES
  CXX_STANDARD 14
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS ON
)
