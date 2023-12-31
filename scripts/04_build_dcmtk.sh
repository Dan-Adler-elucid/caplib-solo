#!/bin/bash

CMAKE_BUILD_TYPE=$1
LINK_SHARED=$2
CMAKE_BUILD_PARALLEL_LEVEL=$3
DCMTK_SOURCE_DIR=$4
DCMTK_BUILD_DIR=$5
BUILD_TOOL_OPTIONS=$6

CMAKE_ARGS=" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL} \
    -DBUILD_APPS:BOOL=ON \
    -DBUILD_SHARED_LIBS:BOOL=${LINK_SHARED} \
    -DBUILD_TESTING:BOOL=OFF \
    -DDCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS:BOOL=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
    -DDCMTK_WITH_OPENSSL:BOOL=ON \
    -DDCMTK_USE_DCMDICTPATH:BOOL=ON \
    -DDCMTK_USE_FIND_PACKAGE:BOOL=ON \
    -DDCMTK_WITH_ICU:BOOL=ON \
    -DDCMTK_WITH_PNG:BOOL=OFF \
    -DDCMTK_WITH_STDLIBC_ICONV:BOOL=ON \
    -DDCMTK_WITH_THREADS:BOOL=ON \
    -DDCMTK_WITH_ZLIB:BOOL=ON \
    -S ${DCMTK_SOURCE_DIR} \
    -B ${DCMTK_BUILD_DIR} \
    "

echo "CMAKE_ARGS=${CMAKE_ARGS}"

# Configure, generate, and build
cmake ${CMAKE_ARGS}
cmake --build ${DCMTK_BUILD_DIR} -- ${BUILD_TOOL_OPTIONS}
