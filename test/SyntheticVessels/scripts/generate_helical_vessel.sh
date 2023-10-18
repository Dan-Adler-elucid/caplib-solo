#!/bin/bash

TUBEGEN_EXE=$1
OUT_DIR=tube_helix

mkdir -p ${OUT_DIR}

HELIX_RADIUS=40
HELIX_HEIGHT=200
HELIX_CYCLES=0.5
START_LUMEN_RADIUS=0.1
END_LUMEN_RADIUS=30
CROSS_SECTION="Circle"
WALL_THICKNESS=0.0
SMOOTHING_STDEV=0
BG_INTENSITY=-1000
LUMEN_INTENSITY=1024
WALL_INTENSITY=512
SPACINGX=0.5
SPACINGY=0.5
SPACINGZ=0.5

# Give the output files very descriptive names to help us keep track:
CENTERLINE="helix-radius_${HELIX_RADIUS}-height_${HELIX_HEIGHT}-cycles_${HELIX_CYCLES}"
LUMEN_MESH="${CENTERLINE}-crossSection${CROSS_SECTION}-startLumenRadius_${START_LUMEN_RADIUS}-endLumenRadius_${END_LUMEN_RADIUS}"
WALL_MESH="${LUMEN_MESH}-wallThickness_${WALL_THICKNESS}"
IMAGE="${WALL_MESH}-spacing_${SPACINGX}_${SPACINGY}_${SPACINGZ}-smoothingStdev_${SMOOTHING_STDEV}"

${TUBEGEN_EXE} \
    --useHelix \
    --helixRadius ${HELIX_RADIUS} \
    --helixHeight ${HELIX_HEIGHT} \
    --numHelixCycles ${HELIX_CYCLES} \
    --helixAxis 1 1 0 \
    --startLumenRadius ${START_LUMEN_RADIUS} \
    --endLumenRadius ${END_LUMEN_RADIUS} \
    --wallThickness ${WALL_THICKNESS} \
    --smoothing ${SMOOTHING_STDEV} \
    --spacing ${SPACINGX} ${SPACINGY} ${SPACINGZ} \
    --backgroundIntensity ${BG_INTENSITY} \
    --lumenIntensity ${LUMEN_INTENSITY} \
    --wallIntensity ${WALL_INTENSITY} \
    --outCenterline ${OUT_DIR}/${CENTERLINE}.vtp \
    --outLumenMesh ${OUT_DIR}/${LUMEN_MESH}.obj \
    --outWallMesh ${OUT_DIR}/${WALL_MESH}.obj \
    --outImage ${OUT_DIR}/${IMAGE}.nii.gz \
    --crossSection${CROSS_SECTION} \
    --showRenderWindow

# -If a reference image is provided with --refImage ref.nii.gz,
#  then --spacing X Y Z need not be
