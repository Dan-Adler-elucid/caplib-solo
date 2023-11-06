cmake_minimum_required( VERSION 3.22 FATAL_ERROR )

if( COMMAND cmake_policy )
  cmake_policy( SET CMP0003 NEW )
endif( COMMAND cmake_policy )

project( commonlib VERSION 1.0.0 LANGUAGES CXX )

#set( CMAKE_CXX_FLAGS "-lcrypto" )

set( DCMTK_DIR ${External_DCMTK_DIR} )

#find_package(CUDA QUIET)
#find_package( CUDAToolkit )
find_package( OpenSSL REQUIRED )
find_package( DCMTK HINTS ${DCMTK_DIR} REQUIRED )

if( NOT DCMTK_FOUND )
    message( FATAL_ERROR "DCMTK was not found. Please set DCMTK_DIR." )
endif()

if(CUDA_FOUND)
  check_language(CUDA)
  if(CMAKE_CUDA_COMPILER)
    enable_language(CUDA)

    include_directories(${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES})

    find_library(NVML_LIBRARY nvidia-ml ${CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES})
  endif()
endif()

set( COMMON_LIBS_DIR ${EVServer_SOURCE_DIR}/services/c++/common/libs )
set( COMMONLIB_DIR ${COMMON_LIBS_DIR}/commonlib )

SET( COMMONLIB_SOURCES
  evDb.cpp
  evData.cpp
  properties.cpp
  props.cpp
  rsa_crypto.cpp
  crypto_utils.cpp
  gpuDeviceQuery.cpp
)

list( TRANSFORM COMMONLIB_SOURCES PREPEND ${COMMONLIB_DIR}/ )

add_definitions(-fPIC)
add_definitions("-IDCMTK/oflog/include")
add_definitions("-IDCMTK/ofstd/include")
add_definitions("-IDCMTK-build/config/include")

add_library( commonlib ${CAPLIB_LINKAGE} )

target_sources( commonlib PRIVATE
  ${COMMONLIB_SOURCES}
)

target_link_directories( commonlib PRIVATE
  ${External_DCMTK_LIB_DIR}
)

target_include_directories( commonlib PRIVATE
  ${COMMONLIB_DIR}
)

# These are 'system' includes in order to ignore compiler warnings:
target_include_directories( commonlib SYSTEM PRIVATE
  ${DCMTK_INCLUDE_DIRS}
)

target_link_libraries( commonlib PRIVATE
  configlib
  mysqlcppconn
  ${DCMTK_LIBRARIES}
  ${NVML_LIBRARY}
  OpenSSL::SSL
  OpenSSL::Crypto
)

target_compile_definitions( commonlib PRIVATE
  ${EBV_COMPILE_DEFINITIONS}
)

if(CUDA_FOUND AND CMAKE_CUDA_COMPILER)
  target_compile_definitions( commonlib PRIVATE CUDA_TOOLKIT_AVAILABLE=1 )
  target_link_libraries( commonlib ${NVML_LIBRARY} )
endif()

set_target_properties( commonlib PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS ON
)
