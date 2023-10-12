cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
  cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( dicomlib VERSION 1.0.0 LANGUAGES C CXX )

set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( DICOMLIB_DIR ${COMMON_LIBS_DIR}/dicomlib )

SET( DICOMLIB_SOURCES
    DICOM_DataDictionary.cpp
    DICOM_DataStructure.cpp
    DICOM_FileFormat.cpp
    DICOM_Helper.cpp
    DICOM_IOD.cpp
    DICOM_VR_Types.cpp
)

list( TRANSFORM DICOMLIB_SOURCES PREPEND ${DICOMLIB_DIR}/ )

add_library( dicomlib ${CAPLIB_LINKAGE}
    ${DICOMLIB_SOURCES}
)

target_include_directories( dicomlib PRIVATE
    ${DICOMLIB_DIR}
)

set_target_properties( dicomlib PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
)
