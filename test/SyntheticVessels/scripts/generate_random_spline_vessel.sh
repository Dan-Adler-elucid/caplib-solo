#!/bin/bash

TUBEGEN_EXE=$1
OUT_DIR=tube_random_spline

mkdir -p ${OUT_DIR}

SPLINE_NUM_POINTS=5
SPLINE_SUBDIV_FACTOR=50
SPLINE_SEED=12345678
SPLINE_SPHERE_RADIUS=50.0
SPLINE_SPHERE_CENTER_X=0.0
SPLINE_SPHERE_CENTER_Y=0.0
SPLINE_SPHERE_CENTER_Z=50.0
START_LUMEN_RADIUS=0.25
END_LUMEN_RADIUS=5
CROSS_SECTION="Einstein"
WALL_THICKNESS=0
SMOOTHING_STDEV=0
BG_INTENSITY=-1000
LUMEN_INTENSITY=1024
WALL_INTENSITY=512
SPACINGX=0.5
SPACINGY=0.5
SPACINGZ=0.5

# Give the output files very descriptive names to help us keep track:
CENTERLINE="randomSpline-numPoints_${SPLINE_NUM_POINTS}-subdiv_${SPLINE_SUBDIV_FACTOR}-seed_${SPLINE_SEED}-sphereRadius_${SPLINE_SPHERE_RADIUS}-sphereCenter_${SPLINE_SPHERE_CENTER_X}_${SPLINE_SPHERE_CENTER_Y}_${SPLINE_SPHERE_CENTER_Z}"
LUMEN_MESH="${CENTERLINE}-crossSection${CROSS_SECTION}-startLumenRadius_${START_LUMEN_RADIUS}-endLumenRadius_${END_LUMEN_RADIUS}"
WALL_MESH="${LUMEN_MESH}-wallThickness_${WALL_THICKNESS}"
IMAGE="${WALL_MESH}-spacing_${SPACINGX}_${SPACINGY}_${SPACINGZ}-smoothingStdev_${SMOOTHING_STDEV}"

${TUBEGEN_EXE} \
    --useRandomSpline \
    --splineSphericalVolume \
    --splineNumRandomPoints ${SPLINE_NUM_POINTS} \
    --splineSubdivisionFactor ${SPLINE_SUBDIV_FACTOR} \
    --splineRandomSeed ${SPLINE_SEED} \
    --splineSphereRadius ${SPLINE_SPHERE_RADIUS} \
    --splineSphereCenter ${SPLINE_SPHERE_CENTER_X} ${SPLINE_SPHERE_CENTER_Y} ${SPLINE_SPHERE_CENTER_Z} \
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
