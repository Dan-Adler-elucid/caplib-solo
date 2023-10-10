cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
    cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( CPRExamples VERSION 1.0.0 LANGUAGES C CXX )

set( ITK_DIR ${External_ITK_DIR} )
set( VTK_DIR ${External_VTK_DIR} )

find_package( VTK HINTS ${VTK_DIR} REQUIRED )
find_package( ITK HINTS ${ITK_DIR} REQUIRED )

if( NOT VTK_FOUND )
    message( FATAL_ERROR "VTK was not found. Please set VTK_DIR." )
endif()

if( ITK_FOUND )
    include( ${ITK_USE_FILE} )
else()
    message( FATAL_ERROR "ITK was not found. Please set ITK_DIR." )
endif()


set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( CAPLIB_CPP_DIR ${COMMON_LIBS_DIR}/caplib/cpp )
set( CPR_EG_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs/test/CPRExamples )

add_executable( ebvTestCPRStraightened )
target_sources( ebvTestCPRStraightened PRIVATE ${CPR_EG_DIR} ebvTestCPRStraightened.cxx )

target_include_directories( ebvTestCPRStraightened SYSTEM PRIVATE
    ${CPR_EG_DIR}
    ${CAPLIB_CPP_DIR}
    ${COMMON_LIBS_DIR}/dicomlib
    ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
    ${ITK_INCLUDE_DIRS} ${VTK_INCLUDE_DIRS} )

target_link_libraries( ebvTestCPRStraightened PRIVATE caplib ${ITK_LIBRARIES} ${VTK_LIBRARIES} )
target_compile_definitions( ebvTestCPRStraightened PRIVATE ${VTK_DEFINITIONS} )
target_compile_options( ebvTestCPRStraightened PRIVATE -O3 )
set_target_properties( ebvTestCPRStraightened PROPERTIES CXX_STANDARD 14 CXX_STANDARD_REQUIRED ON CXX_EXTENSIONS ON )


add_executable( ebvTestCPRStretched )
target_sources( ebvTestCPRStretched PRIVATE ${CPR_EG_DIR} ebvTestCPRStretched.cxx )

target_include_directories( ebvTestCPRStretched SYSTEM PRIVATE
    ${CPR_EG_DIR}
    ${CAPLIB_CPP_DIR}
    ${COMMON_LIBS_DIR}/dicomlib
    ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
    ${ITK_INCLUDE_DIRS} ${VTK_INCLUDE_DIRS} )

target_link_libraries( ebvTestCPRStretched PRIVATE caplib ${ITK_LIBRARIES} ${VTK_LIBRARIES} )
target_compile_definitions( ebvTestCPRStretched PRIVATE ${VTK_DEFINITIONS} )
target_compile_options( ebvTestCPRStretched PRIVATE -O3 )
set_target_properties( ebvTestCPRStretched PROPERTIES CXX_STANDARD 14 CXX_STANDARD_REQUIRED ON CXX_EXTENSIONS ON )


add_executable( ebvTestCurvedPlanarReformatStraight )
target_sources( ebvTestCurvedPlanarReformatStraight PRIVATE ${CPR_EG_DIR} ebvTestCurvedPlanarReformatStraight.cxx )

target_include_directories( ebvTestCurvedPlanarReformatStraight SYSTEM PRIVATE
    ${CPR_EG_DIR}
    ${CAPLIB_CPP_DIR}
    ${COMMON_LIBS_DIR}/dicomlib
    ${EVServer_BUILD_DIR}/services/c++/common/libs/caplib/cpp # for caplib_export.h and caplibModule.h
    ${ITK_INCLUDE_DIRS} ${VTK_INCLUDE_DIRS} )

target_link_libraries( ebvTestCurvedPlanarReformatStraight PRIVATE caplib ${ITK_LIBRARIES} ${VTK_LIBRARIES} )
target_compile_definitions( ebvTestCurvedPlanarReformatStraight PRIVATE ${VTK_DEFINITIONS} )
target_compile_options( ebvTestCurvedPlanarReformatStraight PRIVATE -O3 )
set_target_properties( ebvTestCurvedPlanarReformatStraight PROPERTIES CXX_STANDARD 14 CXX_STANDARD_REQUIRED ON CXX_EXTENSIONS ON )