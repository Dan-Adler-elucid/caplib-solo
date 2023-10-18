#!/bin/bash

CMAKE_BUILD_TYPE=$1
EVServer_BUILD_DIR=$2
EVServer_SOURCE_DIR=$3
GENERATE_EVSERVER_CMAKE=$4
BUILD_TOOL_OPTIONS=$5

pushd ${EVServer_BUILD_DIR} > /dev/null

    if [[ ${GENERATE_EVSERVER_CMAKE} == true ]]; then
        cmake \
            -DEVServer_RENDERING_BACKEND=OnScreen \
            -DEVServer_SUPERBUILD=ON \
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
            -DEVServer_BuildServices=OFF \
            ${EVServer_SOURCE_DIR}
    fi

    cmake --build ${EVServer_BUILD_DIR} ${BUILD_TOOL_OPTIONS}

    if [[ ${GENERATE_EVSERVER_CMAKE} == true ]]; then
        cmake \
            -DEVServer_BuildServices=ON \
            -DBUILD_TESTING=ON \
            ${EVServer_SOURCE_DIR}
    fi

    cmake --build ${EVServer_BUILD_DIR} ${BUILD_TOOL_OPTIONS}

popd > /dev/null