#!/bin/bash

CMAKE_BUILD_TYPE=$1
LINK_SHARED=$2
CMAKE_BUILD_PARALLEL_LEVEL=$3
IVANTK_SOURCE_DIR=$4
IVANTK_BUILD_DIR=$5
ITK_BUILD_DIR=$6
VTK_BUILD_DIR=$7
BUILD_TOOL_OPTIONS=$8

CMAKE_ARGS=" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL} \
    -DITK_DIR:PATH=${ITK_BUILD_DIR} \
    -DVTK_DIR:PATH=${VTK_BUILD_DIR} \
    -DIVAN_BUILD_SHARED_LIBS:BOOL=${LINK_SHARED} \
    -S ${IVANTK_SOURCE_DIR} \
    -B ${IVANTK_BUILD_DIR} \
    "

echo "CMAKE_ARGS=${CMAKE_ARGS}"

# Configure, generate, and build
cmake ${CMAKE_ARGS}
cmake --build ${IVANTK_BUILD_DIR} -- ${BUILD_TOOL_OPTIONS}
