cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
    cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( disp VERSION 1.0.0 LANGUAGES C CXX )

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


add_executable( disp )

set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( CAPLIB_CPP_DIR ${COMMON_LIBS_DIR}/caplib/cpp )
set( DISP_CPP_DIR ${COMMON_LIBS_DIR}/test/utils/disp )


if( VTK_OPENGL_HAS_EGL )
    set( EBV_COMPILE_DEFINITIONS EBV_USE_EGL )
    find_package( OpenGL REQUIRED COMPONENTS OpenGL EGL GLX )

    set( PROXY_SOURCES ${CAPLIB_CPP_DIR}/ebvEGLRenderWindowProxy.cxx )
    set( CAPLIB_SOURCES ${CAPLIB_SOURCES} ${CAPLIB_CPP_DIR}/ebvEGLRenderWindow.cxx ) # Use custom EGL window
    set( GRAPHICS_INCLUDE_DIRS ${OPENGL_INCLUDE_DIRS} ${EGL_INCLUDE_DIRS} )

elseif( VTK_OPENGL_HAS_MESA ) # VTK_OPENGL_HAS_OSMESA?
    set( EBV_COMPILE_DEFINITIONS EBV_USE_MESA )

else()
    set( EBV_COMPILE_DEFINITIONS EBV_USE_X )
    set( PROXY_SOURCES ${CAPLIB_CPP_DIR}/ebvXOpenGLRenderWindowProxy.cxx )
endif()


target_sources( disp PRIVATE
    ${DISP_CPP_DIR}/disp.cxx
    ${PROXY_SOURCES}

    # ${COMMON_LIBS_DIR}/dicomlib/dicom.cpp
    ${COMMON_LIBS_DIR}/dicomlib/DICOM_DataDictionary.cpp
    ${COMMON_LIBS_DIR}/dicomlib/DICOM_DataStructure.cpp
    ${COMMON_LIBS_DIR}/dicomlib/DICOM_FileFormat.cpp
    ${COMMON_LIBS_DIR}/dicomlib/DICOM_Helper.cpp
    ${COMMON_LIBS_DIR}/dicomlib/DICOM_IOD.cpp
    ${COMMON_LIBS_DIR}/dicomlib/DICOM_VR_Types.cpp
)

target_link_directories( disp PRIVATE
    ${External_DCMTK_LIB_DIR}
)

target_include_directories( disp PRIVATE
    ${CAPLIB_CPP_DIR}
    ${COMMON_LIBS_DIR}/configlib
    ${COMMON_LIBS_DIR}/dicomlib
    ${COMMON_LIBS_DIR}/SceneSerialization
    ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
    ${EVServer_BUILD_DIR}/services/c++/common/libs/SceneSerialization # for sceneserialization_export.h
)

target_include_directories( disp SYSTEM PRIVATE
    ${ITK_INCLUDE_DIRS}
    ${VTK_INCLUDE_DIRS}
    ${DCMTK_INCLUDE_DIRS}
    ${External_BOOST_SOURCE_DIR}
)

target_link_libraries( disp PRIVATE
    caplib
    SceneSerialization
    ${ITK_LIBRARIES}
    ${VTK_LIBRARIES}
)

target_compile_definitions( disp PRIVATE
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

set_target_properties( disp PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
    )

vtk_module_autoinit(
    TARGETS disp
    MODULES ${VTK_LIBRARIES}
)
