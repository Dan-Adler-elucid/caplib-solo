#!/bin/bash

CMAKE_BUILD_TYPE=$1
ITK_SOURCE_DIR=$2
ITK_BUILD_DIR=$3
VTK_BUILD_DIR=$4
BUILD_TOOL_OPTIONS=$5

CMAKE_ARGS=" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DVTK_DIR:PATH=${VTK_BUILD_DIR} \
    -DModule_ITKVtkGlue:BOOL=ON \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_TESTING:BOOL=OFF \
    -DModule_ITKReview:BOOL=ON \
    -DModule_MinimalPathExtraction:BOOL=ON \
    -DITK_BUILD_DEFAULT_MODULES:BOOL=ON \
    -DITK_LEGACY_SILENT:BOOL=ON \
    -DCMAKE_POLICY_DEFAULT_CMP0106=OLD \
    -S ${ITK_SOURCE_DIR} \
    -B ${ITK_BUILD_DIR} \
    "

echo "CMAKE_ARGS=${CMAKE_ARGS}"

# Configure, generate, and build
cmake ${CMAKE_ARGS}
cmake --build ${ITK_BUILD_DIR} -- ${BUILD_TOOL_OPTIONS}
