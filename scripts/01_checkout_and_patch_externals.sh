#!/bin/bash

EVServer_SOURCE_DIR=$1
VTK_VERSION=$2
ITK_VERSION=$3
DCMTK_VERSION=$4
BOOST_VERSION=$5
VTK_SOURCE_DIR=$6
ITK_SOURCE_DIR=$7
DCMTK_SOURCE_DIR=$8
BOOST_SOURCE_DIR=$9

# Checkout correct commit of VTK and apply patch
pushd ${VTK_SOURCE_DIR}
    git checkout ${VTK_VERSION}
    git apply ${EVServer_SOURCE_DIR}/ThirdParty/Patches/VTK_${VTK_VERSION}.patch
popd

# Checkout correct commit of ITK and apply patch
pushd ${ITK_SOURCE_DIR}
    git checkout ${ITK_VERSION}
    git apply ${EVServer_SOURCE_DIR}/ThirdParty/Patches/ITK_${ITK_VERSION}_VTK_${VTK_VERSION}.patch
popd

# Checkout correct commit of DCMTK
pushd ${DCMTK_SOURCE_DIR}
    git checkout ${DCMTK_VERSION}
popd

# Checkout correct commit of Boost and install the headers in this folder
pushd ${BOOST_SOURCE_DIR}
    git checkout ${BOOST_VERSION}
    git submodule update --init --recursive

    ./bootstrap.sh
    ./b2 headers
    mv boost build-${BOOST_VERSION}
popd
