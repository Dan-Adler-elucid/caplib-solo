#!/bin/bash

# Build steps:
DO_01_checkout_and_patch_externals=true
DO_02_build_vtk=true
DO_03_build_itk=true
DO_04_build_dcmtk=true
DO_05_build_caplib=true

# Root directory containing EVServer and caplib-solo
ROOT_DIR=~/dev # SET ME
EVServer_SOURCE_DIR=${ROOT_DIR}/EVServer # SET ME
EVServer_BINARY_DIR=/inst/EVServer-Release-HwOffS # SET ME
CAPLIB_SOLO_SOURCE_DIR=${ROOT_DIR}/caplib # SET ME

GET_SHA_CMD="pushd ${EVServer_SOURCE_DIR} > /dev/null; git rev-parse --short HEAD; popd > /dev/null"
EVSERVER_SHA=`eval " ${GET_SHA_CMD}"`
echo "EVSERVER_SHA = ${EVSERVER_SHA}"

# External library source directories
CAPLIB_EXTERNAL_DIR=${CAPLIB_SOLO_SOURCE_DIR}/externals
BOOST_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/boost
DCMTK_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/dcmtk
ITK_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/ITK
VTK_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/VTK

# External library versions:
VTK_VERSION=c8d614697cc9785fa61065edfbc1122553e955a4 # Commit that just precedes v9.1.0.rc1
ITK_VERSION=v4.12.2
DCMTK_VERSION=DCMTK-3.6.7
BOOST_VERSION=boost-1.83.0 # Note: not specified in EVServer build!

# Build flags:
declare -a CMAKE_BUILD_TYPES=($1 $2) # i.e. (Release Debug)
CAPLIB_LINKAGE=SHARED # i.e. SHARED, STATIC
EVServer_DEPLOY_TYPE=Development # i.e. Development, Production
EVServer_RENDERING_BACKEND=OnScreen # i.e. HardwareOffScreen, SoftwareOffScreen, OnScreen
BUILD_TOOL_OPTIONS="-j 12"

if [ ${#CMAKE_BUILD_TYPES[@]} -eq 0 ]; then
    CMAKE_BUILD_TYPES=(Release Debug)
fi

for CMAKE_BUILD_TYPE in ${CMAKE_BUILD_TYPES[@]}
do

    # Build directories, showing info about the build:
    VTK_BUILD_DIR=${VTK_SOURCE_DIR}/build-${VTK_VERSION}-${CMAKE_BUILD_TYPE}-${EVServer_RENDERING_BACKEND}-${EVServer_DEPLOY_TYPE}
    ITK_BUILD_DIR=${ITK_SOURCE_DIR}/build-${ITK_VERSION}-${CMAKE_BUILD_TYPE}
    DCMTK_BUILD_DIR=${DCMTK_SOURCE_DIR}/build-${DCMTK_VERSION}-${CMAKE_BUILD_TYPE}
    DCMTK_LIB_DIR=${DCMTK_BUILD_DIR}/lib
    BOOST_BUILD_DIR=${BOOST_SOURCE_DIR}/build-${BOOST_VERSION}
    CAPLIB_BUILD_DIR=${CAPLIB_SOLO_SOURCE_DIR}/build-${EVSERVER_SHA}-${CMAKE_BUILD_TYPE}-${EVServer_RENDERING_BACKEND}-${EVServer_DEPLOY_TYPE}-${CAPLIB_LINKAGE}

    if [[ ${DO_01_checkout_and_patch_externals} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 01) Checkout and patch external libraries"

        ./scripts/01_checkout_and_patch_externals.sh \
            ${EVServer_SOURCE_DIR} \
            ${VTK_VERSION} \
            ${ITK_VERSION} \
            ${DCMTK_VERSION} \
            ${BOOST_VERSION} \
            ${VTK_SOURCE_DIR} \
            ${ITK_SOURCE_DIR} \
            ${DCMTK_SOURCE_DIR} \
            ${BOOST_SOURCE_DIR}
    fi

    if [[ ${DO_02_build_vtk} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 02) Build VTK"

        ./scripts/02_build_vtk.sh \
            ${CMAKE_BUILD_TYPE} \
            ${VTK_SOURCE_DIR} \
            ${VTK_BUILD_DIR} \
            ${EVServer_DEPLOY_TYPE} \
            ${EVServer_RENDERING_BACKEND} \
            ${BUILD_TOOL_OPTIONS}
    fi

    if [[ ${DO_03_build_itk} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 03) Build ITK"

        ./scripts/03_build_itk.sh \
            ${CMAKE_BUILD_TYPE} \
            ${ITK_SOURCE_DIR} \
            ${ITK_BUILD_DIR} \
            ${VTK_BUILD_DIR} \
            ${BUILD_TOOL_OPTIONS}
    fi

    if [[ ${DO_04_build_dcmtk} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 04) Build DCMTK"

        ./scripts/04_build_dcmtk.sh \
            ${CMAKE_BUILD_TYPE} \
            ${DCMTK_SOURCE_DIR} \
            ${DCMTK_BUILD_DIR} \
            ${BUILD_TOOL_OPTIONS}
    fi

    if [[ ${DO_05_build_caplib} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 05) Build caplib"

        ./scripts/05_build_caplib.sh \
            ${CMAKE_BUILD_TYPE} \
            ${CAPLIB_SOLO_SOURCE_DIR} \
            ${CAPLIB_BUILD_DIR} \
            ${VTK_BUILD_DIR} \
            ${ITK_BUILD_DIR} \
            ${DCMTK_BUILD_DIR} \
            ${DCMTK_LIB_DIR} \
            ${BOOST_BUILD_DIR} \
            ${EVServer_SOURCE_DIR} \
            ${EVServer_BINARY_DIR} \
            ${CAPLIB_LINKAGE} \
            ${BUILD_TOOL_OPTIONS}
    fi

done