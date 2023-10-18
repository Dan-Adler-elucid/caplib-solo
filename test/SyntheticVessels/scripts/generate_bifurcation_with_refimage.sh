#!/bin/bash

TUBEGEN_EXE=$1
C3D_EXE=$2

# C3D is the Convert3D executable, which is a command-line medical image processing tool
# that ships with ITK-SNAP. Convert3D can also be downloaded on its own.
# -Main webpage: http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Convert3D
# -Download: http://www.itksnap.org/pmwiki/pmwiki.php?n=Downloads.C3D
# -Documentation: http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Documentation

OUT_DIR=tube_helix_bifurc_from_refimage

mkdir -p ${OUT_DIR}

# General idea for creating the bifurcation image:
# 1) Use tubegen to create binary images (no smoothing) of two helices with opposite
#    rotation sense, one clockwise and the other counter-clockwise.
# 2) Use Convert3D to add the two helix images together and smooth the result.

HELIX_RADIUS=75
HELIX_HEIGHT=150
HELIX_CYCLES=0.85
START_LUMEN_RADIUS=1
END_LUMEN_RADIUS=5
WALL_THICKNESS=0

# No smoothing done in tubegen
SMOOTHING_STDEV=0.0

# Use foreground = 1, background = 0 (i.e. a binary mask of the tube)
BG_INTENSITY=0
LUMEN_INTENSITY=1

REF_IMAGE=../data/helix_refimage.nii.gz

# Give the output files very descriptive names to help us keep track:
CENTERLINE="helix-radius_${HELIX_RADIUS}-height_${HELIX_HEIGHT}-cycles_${HELIX_CYCLES}"
LUMEN_MESH="${CENTERLINE}-startLumenRadius_${START_LUMEN_RADIUS}-endLumenRadius_${END_LUMEN_RADIUS}"
WALL_MESH="${LUMEN_MESH}-wallThickness_${WALL_THICKNESS}"
IMAGE="${WALL_MESH}-smoothingStdev_${SMOOTHING_STDEV}"

# Create a right-handed, counter-clockwise (CCW) helix, which is the default rotation sense
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
    --outImage ${OUT_DIR}/${IMAGE}-rotationSense_CCW.nii.gz # CCW sense

# Create a left-handed, clockwise helix using the --helixClockwise option
${TUBEGEN_EXE} \
    --useHelix \
    --helixRadius ${HELIX_RADIUS} \
    --helixHeight ${HELIX_HEIGHT} \
    --numHelixCycles ${HELIX_CYCLES} \
    --helixClockwise \
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
    --outImage ${OUT_DIR}/${IMAGE}-rotationSense_CW.nii.gz # CW sense

# As output by tubegen, both images have voxel (0,0,0) set to 1000,
# which is necessary for them to load in EV. This step creates a new image
# called "dot.nii.gz" that consists of all black voxels except for voxel (0,0,0)
# set to 1. We will add back dot.nii.gz to the final result in the last step.

# Create dot.nii.gz, which only has voxel (0,0,0) equal to 1.
${C3D_EXE} \
    ${OUT_DIR}/${IMAGE}-rotationSense_CCW.nii.gz \
    -replace 1 0 1000 1 \
    -type short \
    -o ${OUT_DIR}/dot.nii.gz

# 1) Load the two helix masks (both CCW and CW senses), replace intensity 1000
#    with intensity 0. Intensity 1000 only occurs at voxel (0,0,0).
# 2) Add the masks together.
# 3) Replace intensity 2 with 1 (since there is overlap of the binary masks
#    where the helices join) and replace intensity 0 with -1000 (background).
# 4) Smooth with a Gaussian kernel of 0.5mm.
# 5) Output as short (int16).
${C3D_EXE} \
    ${OUT_DIR}/${IMAGE}-rotationSense_CCW.nii.gz \
    -replace 1000 0 \
    ${OUT_DIR}/${IMAGE}-rotationSense_CW.nii.gz \
    -replace 1000 0 \
    -add \
    -replace 2 1 0 -1000 \
    -smooth 0.5mm \
    -type short \
    -o ${OUT_DIR}/${IMAGE}-bifurcation.nii.gz

# Set voxel (0,0,0) to 1000 by adding 2000 to its current value.
# Recall that voxel (0,0,0) is set at -1000 prior to this operation.
${C3D_EXE} \
    ${OUT_DIR}/dot.nii.gz \
    -scale 2000 \
    ${OUT_DIR}/${IMAGE}-bifurcation.nii.gz \
    -add \
    -type short \
    -o ${OUT_DIR}/${IMAGE}-bifurcation.nii.gz
