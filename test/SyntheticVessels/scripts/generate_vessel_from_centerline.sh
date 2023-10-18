#!/bin/bash

TUBEGEN_EXE=$1
OUT_DIR=tube_vessel_from_centerline

mkdir -p ${OUT_DIR}

IN_CENTERLINE=../data/vessel_right_coronary.vtp
REF_IMAGE=../data/ct_volume_refimage.nii.gz
START_LUMEN_RADIUS=3
END_LUMEN_RADIUS=0.25
WALL_THICKNESS=1
SMOOTHING_STDEV=0
LUMEN_INTENSITY=380
WALL_INTENSITY=0
BACKGROUND_INTENSITY=-1000

# Give the output files very descriptive names to help us keep track:
OUT_CENTERLINE="RightCoronary"
LUMEN_MESH="${OUT_CENTERLINE}-startLumenRadius_${START_LUMEN_RADIUS}-endLumenRadius_${END_LUMEN_RADIUS}"
WALL_MESH="${LUMEN_MESH}-wallThickness_${WALL_THICKNESS}"
IMAGE="${WALL_MESH}-refImageUsed-smoothingStdev_${SMOOTHING_STDEV}"

${TUBEGEN_EXE} \
    --useCenterlineFile \
    --centerline ${IN_CENTERLINE} \
    --startLumenRadius ${START_LUMEN_RADIUS} \
    --endLumenRadius ${END_LUMEN_RADIUS} \
    --wallThickness ${WALL_THICKNESS} \
    --smoothing ${SMOOTHING_STDEV} \
    --backgroundIntensity ${BACKGROUND_INTENSITY} \
    --lumenIntensity ${LUMEN_INTENSITY} \
    --wallIntensity ${WALL_INTENSITY} \
    --outCenterline ${OUT_DIR}/${OUT_CENTERLINE}.vtp \
    --outLumenMesh ${OUT_DIR}/${LUMEN_MESH}.obj \
    --outWallMesh ${OUT_DIR}/${WALL_MESH}.obj \
    --refImage ${REF_IMAGE} \
    --outImage ${OUT_DIR}/${IMAGE}.nii.gz \
    --showRenderWindow

# -If a reference image is provided with --refImage ref.nii.gz,
#  then --spacing X Y Z need not be
