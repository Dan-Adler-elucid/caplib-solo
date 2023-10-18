#!/bin/bash

TUBEGEN_EXE=$1
OUT_DIR=tube_helix2

mkdir -p ${OUT_DIR}

HELIX_RADIUS=64
HELIX_HEIGHT=256
HELIX_CYCLES=8
START_LUMEN_RADIUS=2
END_LUMEN_RADIUS=8
WALL_THICKNESS=2
SMOOTHING=2
LUMEN_INTENSITY=1024
WALL_INTENSITY=512
SPACINGX=0.40
SPACINGY=0.40
SPACINGZ=0.50

# Give the output files very descriptive names to help us keep track:
CENTERLINE="helix-radius_${HELIX_RADIUS}-height_${HELIX_HEIGHT}-cycles_${HELIX_CYCLES}"
LUMEN_MESH="${CENTERLINE}-startLumenRadius_${START_LUMEN_RADIUS}-endLumenRadius_${END_LUMEN_RADIUS}"
WALL_MESH="${LUMEN_MESH}-wallThickness_${WALL_THICKNESS}"
IMAGE="${WALL_MESH}-spacing_${SPACINGX}_${SPACINGY}_${SPACINGZ}-smoothingStdev_${SMOOTHING}"

${TUBEGEN_EXE} \
    --useHelix \
    --helixRadius ${HELIX_RADIUS} \
    --helixHeight ${HELIX_HEIGHT} \
    --numHelixCycles ${HELIX_CYCLES} \
    --startLumenRadius ${START_LUMEN_RADIUS} \
    --endLumenRadius ${END_LUMEN_RADIUS} \
    --wallThickness ${WALL_THICKNESS} \
    --smoothing ${SMOOTHING} \
    --spacing ${SPACINGX} ${SPACINGY} ${SPACINGZ} \
    --lumenIntensity ${LUMEN_INTENSITY} \
    --wallIntensity ${WALL_INTENSITY} \
    --outCenterline ${OUT_DIR}/${CENTERLINE}.vtp \
    --outLumenMesh ${OUT_DIR}/${LUMEN_MESH}.obj \
    --outWallMesh ${OUT_DIR}/${WALL_MESH}.obj \
    --outImage ${OUT_DIR}/${IMAGE}.nii.gz


# Other parameters:
#
# -If a reference image is provided with --refImage ref.nii.gz,
#  then --spacing X Y Z need not be
#
# -Render the tube with --showRenderWindow
