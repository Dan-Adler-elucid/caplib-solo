#!/bin/bash

# Build steps:
DO_01_checkout_and_patch_externals=false # <-- SET ME
DO_02_build_vtk=false # <-- SET ME
DO_03_build_itk=false # <-- SET ME
DO_04_build_dcmtk=false # <-- SET ME
DO_05_build_ivantk=false # <-- SET ME
DO_06_build_evserver=true # <-- SET ME
DO_07_build_caplib=true # <-- SET ME

# Flag to generate the CMake build for EVServer (as part of step 06)
GENERATE_EVSERVER_CMAKE=true # <-- SET ME

# EVServer source, EVServer build, and caplib-solo source directories
EVServer_SOURCE_DIR=/inst/adler/EVServer # <-- SET ME
EVServer_RELEASE_BUILD_DIR=/inst/adler/EVServer-Release-OnScreen # <-- SET ME
EVServer_DEBUG_BUILD_DIR=/inst/adler/EVServer-Debug-OnScreen # <-- SET ME
CAPLIB_SOLO_SOURCE_DIR=~/dev/caplib-solo # <-- SET ME

# External library versions:
VTK_VERSION=c8d614697cc9785fa61065edfbc1122553e955a4 # Commit that just precedes v9.1.0.rc1  <-- SET ME
ITK_VERSION=v4.12.2 # <-- SET ME
DCMTK_VERSION=DCMTK-3.6.7 # <-- SET ME
BOOST_VERSION=boost-1.83.0 # Note: not specified in EVServer build!  <-- SET ME
IVANTK_VERSION=a9e1cd6ee39986c7504ded80c2ab9b568bafc1f2

# Build flags:
declare -a CMAKE_BUILD_TYPES=($1 $2) # i.e. (Release Debug)  <-- SET ME
CAPLIB_LINKAGE=SHARED # i.e. SHARED, STATIC  <-- SET ME
EVServer_DEPLOY_TYPE=Development # i.e. Development, Production  <-- SET ME
EVServer_RENDERING_BACKEND=OnScreen # i.e. HardwareOffScreen, SoftwareOffScreen, OnScreen  <-- SET ME
BUILD_TOOL_OPTIONS="-j 4" # <-- SET ME

# External library source directories
CAPLIB_EXTERNAL_DIR=${CAPLIB_SOLO_SOURCE_DIR}/externals
BOOST_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/boost
DCMTK_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/dcmtk
IVANTK_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/ivantk
ITK_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/ITK
VTK_SOURCE_DIR=${CAPLIB_EXTERNAL_DIR}/VTK

GET_SHA_CMD="pushd ${EVServer_SOURCE_DIR} > /dev/null; git rev-parse --short HEAD; popd > /dev/null"
EVSERVER_SHA=`eval " ${GET_SHA_CMD}"`
echo "EVSERVER_SHA = ${EVSERVER_SHA}"

if [ ${#CMAKE_BUILD_TYPES[@]} -eq 0 ]; then
    CMAKE_BUILD_TYPES=(Release Debug)
fi

if [[ ${DO_01_checkout_and_patch_externals} == true ]]; then
    echo "--------------------------------------------------"
    echo "(STAGE 01) Checkout and patch external libraries"

    IVANTK_PATCH_FILE=${CAPLIB_SOLO_SOURCE_DIR}/patch/ivantk_patch.txt

    ./scripts/01_checkout_and_patch_externals.sh \
        ${EVServer_SOURCE_DIR} \
        ${VTK_VERSION} \
        ${ITK_VERSION} \
        ${DCMTK_VERSION} \
        ${BOOST_VERSION} \
        ${IVANTK_VERSION} \
        ${VTK_SOURCE_DIR} \
        ${ITK_SOURCE_DIR} \
        ${DCMTK_SOURCE_DIR} \
        ${BOOST_SOURCE_DIR} \
        ${IVANTK_SOURCE_DIR} \
        ${IVANTK_PATCH_FILE}
fi

for CMAKE_BUILD_TYPE in ${CMAKE_BUILD_TYPES[@]}
do
    # Build directories, showing info about the build:
    VTK_BUILD_DIR=${VTK_SOURCE_DIR}/build-${VTK_VERSION}-${CMAKE_BUILD_TYPE}-${EVServer_RENDERING_BACKEND}-${EVServer_DEPLOY_TYPE}
    ITK_BUILD_DIR=${ITK_SOURCE_DIR}/build-${ITK_VERSION}-${CMAKE_BUILD_TYPE}
    DCMTK_BUILD_DIR=${DCMTK_SOURCE_DIR}/build-${DCMTK_VERSION}-${CMAKE_BUILD_TYPE}
    DCMTK_LIB_DIR=${DCMTK_BUILD_DIR}/lib
    BOOST_BUILD_DIR=${BOOST_SOURCE_DIR}/build-${BOOST_VERSION}
    IVANTK_BUILD_DIR=${IVANTK_SOURCE_DIR}/build-${IVANTK_VERSION}-${CMAKE_BUILD_TYPE}
    CAPLIB_BUILD_DIR=${CAPLIB_SOLO_SOURCE_DIR}/build-${EVSERVER_SHA}-${CMAKE_BUILD_TYPE}-${EVServer_RENDERING_BACKEND}-${EVServer_DEPLOY_TYPE}-${CAPLIB_LINKAGE}

    EVServer_BUILD_DIR=""
    if [[ ${CMAKE_BUILD_TYPE} == "Release" ]]; then
        EVServer_BUILD_DIR=${EVServer_RELEASE_BUILD_DIR}
    elif [[ ${CMAKE_BUILD_TYPE} == "Debug" ]]; then
        EVServer_BUILD_DIR=${EVServer_DEBUG_BUILD_DIR}
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

    if [[ ${DO_05_build_ivantk} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 05) Build IvanTK"

        ./scripts/05_build_ivantk.sh \
            ${CMAKE_BUILD_TYPE} \
            ${IVANTK_SOURCE_DIR} \
            ${IVANTK_BUILD_DIR} \
            ${ITK_BUILD_DIR} \
            ${VTK_BUILD_DIR} \
            ${BUILD_TOOL_OPTIONS}
    fi

    if [[ ${DO_06_build_evserver} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 06) Build EVServer"

        ./scripts/06_build_evserver.sh \
            ${CMAKE_BUILD_TYPE} \
            ${EVServer_BUILD_DIR} \
            ${EVServer_SOURCE_DIR} \
            ${GENERATE_EVSERVER_CMAKE} \
            ${BUILD_TOOL_OPTIONS}
    fi

    if [[ ${DO_07_build_caplib} == true ]]; then
        echo "--------------------------------------------------"
        echo "(STAGE 07) Build caplib"

        ./scripts/07_build_caplib.sh \
            ${CMAKE_BUILD_TYPE} \
            ${CAPLIB_SOLO_SOURCE_DIR} \
            ${CAPLIB_BUILD_DIR} \
            ${VTK_BUILD_DIR} \
            ${ITK_BUILD_DIR} \
            ${DCMTK_BUILD_DIR} \
            ${DCMTK_LIB_DIR} \
            ${BOOST_BUILD_DIR} \
            ${IVANTK_BUILD_DIR} \
            ${EVServer_SOURCE_DIR} \
            ${EVServer_BUILD_DIR} \
            ${CAPLIB_LINKAGE} \
            ${BUILD_TOOL_OPTIONS}
    fi
done
