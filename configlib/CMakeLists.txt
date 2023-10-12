cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
  cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( configlib VERSION 1.0.0 LANGUAGES C CXX )

set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( CONFIGLIB_DIR ${COMMON_LIBS_DIR}/configlib )

SET( CONFIGLIB_SOURCES
    EVconfig.cxx
)

list( TRANSFORM CONFIGLIB_SOURCES PREPEND ${CONFIGLIB_DIR}/ )

add_library( configlib ${CAPLIB_LINKAGE}
    ${CONFIGLIB_SOURCES}
)

target_include_directories( configlib PRIVATE
    ${CONFIGLIB_DIR}
)

set_target_properties( configlib PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
)
