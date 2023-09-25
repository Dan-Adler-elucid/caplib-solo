#!/bin/bash

CMAKE_BUILD_TYPE=$1
CAPLIB_SOLO_SOURCE_DIR=$2
CAPLIB_BUILD_DIR=$3
VTK_BUILD_DIR=$4
ITK_BUILD_DIR=$5
DCMTK_BUILD_DIR=$6
DCMTK_LIB_DIR=$7
BOOST_BUILD_DIR=$8
IVANTK_BUILD_DIR=$9
EVServer_SOURCE_DIR=${10}
EVServer_BUILD_DIR=${11}
CAPLIB_LINKAGE=${12}
BUILD_TOOL_OPTIONS=${13}

# Note that CMAKE_BUILD_TYPE variable is ignored by IDEs

CMAKE_ARGS=" \
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} \
    -DExternal_VTK_DIR:PATH=${VTK_BUILD_DIR} \
    -DExternal_ITK_DIR:PATH=${ITK_BUILD_DIR} \
    -DExternal_DCMTK_DIR:PATH=${DCMTK_BUILD_DIR} \
    -DExternal_DCMTK_LIB_DIR:PATH=${DCMTK_LIB_DIR} \
    -DExternal_BOOST_BUILD_DIR:PATH=${BOOST_BUILD_DIR} \
    -DExternal_IVANTK_DIR:PATH=${IVANTK_BUILD_DIR} \
    -DITK_DIR:PATH=${ITK_BUILD_DIR} \
    -DEVServer_SOURCE_DIR:PATH=${EVServer_SOURCE_DIR} \
    -DEVServer_BUILD_DIR:PATH=${EVServer_BUILD_DIR} \
    -DCAPLIB_LINKAGE:STRING=${CAPLIB_LINKAGE} \
    -S ${CAPLIB_SOLO_SOURCE_DIR} \
    -B ${CAPLIB_BUILD_DIR} \
    "

echo "CMAKE_ARGS=${CMAKE_ARGS}"

# Configure, generate, and build
cmake ${CMAKE_ARGS}
cmake --build ${CAPLIB_BUILD_DIR} -- ${BUILD_TOOL_OPTIONS}
