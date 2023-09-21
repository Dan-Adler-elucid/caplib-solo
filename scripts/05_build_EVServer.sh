#!/bin/bash

CMAKE_BUILD_TYPE=$1
EVServer_BUILD_DIR=$2
EVServer_SOURCE_DIR=$3

cmake -GNinja \
    -DEVServer_RENDERING_BACKEND=OnScreen \
    -DEVServer_SUPERBUILD=ON \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DEVServer_BuildServices=OFF \
    ${EVServer_SOURCE_DIR}

cmake --build ${EVServer_BUILD_DIR}

cmake \
    -DEVServer_BuildServices=ON \
    -DBUILD_TESTING=ON \
    ${EVServer_SOURCE_DIR}

cmake --build ${EVServer_BUILD_DIR}