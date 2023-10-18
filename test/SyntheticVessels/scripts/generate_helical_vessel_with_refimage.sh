#!/bin/bash

TUBEGEN_EXE=$1
OUT_DIR=tube_helix_from_refimage

mkdir -p ${OUT_DIR}

HELIX_RADIUS=75
HELIX_HEIGHT=150
HELIX_CYCLES=1
START_LUMEN_RADIUS=1
END_LUMEN_RADIUS=5
WALL_THICKNESS=0
SMOOTHING_STDEV=0.5
BG_INTENSITY=-1000
LUMEN_INTENSITY=380
REF_IMAGE=../data/helix_refimage.nii.gz

# Give the output files very descriptive names to help us keep track:
CENTERLINE="helix-radius_${HELIX_RADIUS}-height_${HELIX_HEIGHT}-cycles_${HELIX_CYCLES}"
LUMEN_MESH="${CENTERLINE}-startLumenRadius_${START_LUMEN_RADIUS}-endLumenRadius_${END_LUMEN_RADIUS}"
WALL_MESH="${LUMEN_MESH}-wallThickness_${WALL_THICKNESS}"
IMAGE="${WALL_MESH}-smoothingStdev_${SMOOTHING_STDEV}"

${TUBEGEN_EXE} \
    --useHelix \
    --helixRadius ${HELIX_RADIUS} \
    --helixHeight ${HELIX_HEIGHT} \
    --numHelixCycles ${HELIX_CYCLES} \
    --startLumenRadius ${START_LUMEN_RADIUS} \
    --endLumenRadius ${END_LUMEN_RADIUS} \
    --wallThickness ${WALL_THICKNESS} \
    --smoothing ${SMOOTHING_STDEV} \
    --backgroundIntensity ${BG_INTENSITY} \
    --lumenIntensity ${LUMEN_INTENSITY} \
    --outCenterline ${OUT_DIR}/${CENTERLINE}.vtp \
    --outLumenMesh ${OUT_DIR}/${LUMEN_MESH}.obj \
    --outWallMesh ${OUT_DIR}/${WALL_MESH}.obj \
    --refImage ${REF_IMAGE} \
    --outImage ${OUT_DIR}/${IMAGE}.nii.gz \
    --outDicomSeries ${OUT_DIR}/dicom-${IMAGE} slice \
    --showRenderWindow

# -If a reference image is provided with --refImage ref.nii.gz,
#  then --spacing X Y Z need not be
