cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
  cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( SceneSerialization VERSION 1.0.0 LANGUAGES C CXX )

set( VTK_DIR ${External_VTK_DIR} )

find_package( VTK HINTS ${VTK_DIR} REQUIRED )

if( NOT VTK_FOUND )
    message( FATAL_ERROR "VTK was not found. Please set VTK_DIR." )
endif()


set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( SCENE_SERIALIZATION_DIR ${COMMON_LIBS_DIR}/SceneSerialization )

SET( SCENE_SERIALIZATION_SOURCES
    vtkXMLColorTransferFunctionReader.cxx
    vtkXMLColorTransferFunctionWriter.cxx
    vtkXMLIOBase.cxx
    vtkXMLKWParser.cxx
    vtkXMLObjectReader.cxx
    vtkXMLObjectWriter.cxx
    vtkXMLPiecewiseFunctionReader.cxx
    vtkXMLPiecewiseFunctionWriter.cxx
    vtkXMLRenderViewBaseReader.cxx
    vtkXMLRenderViewReader.cxx
    vtkXMLVolumePropertyReader.cxx
    vtkXMLVolumePropertyWriter.cxx
    vtkXMLDisplayInterface.cxx
)

list( TRANSFORM SCENE_SERIALIZATION_SOURCES PREPEND ${SCENE_SERIALIZATION_DIR}/XML/ )

add_library( SceneSerialization ${CAPLIB_LINKAGE}
    ${SCENE_SERIALIZATION_SOURCES}
)

target_include_directories( SceneSerialization PRIVATE
    ${SCENE_SERIALIZATION_DIR}
    ${COMMON_LIBS_DIR}/configlib
    ${COMMON_LIBS_DIR}/dicomlib
    ${EVServer_BUILD_DIR}/services/c++/common/libs/SceneSerialization # for sceneserialization_export.h
)

target_include_directories( SceneSerialization SYSTEM PRIVATE
    ${VTK_INCLUDE_DIRS}
)

include( GenerateExportHeader )
generate_export_header( SceneSerialization )

target_link_libraries( SceneSerialization PRIVATE
    configlib
    ${VTK_LIBRARIES}
)

target_compile_definitions( SceneSerialization PRIVATE
    ${VTK_DEFINITIONS}
)

set_target_properties( SceneSerialization PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
)
