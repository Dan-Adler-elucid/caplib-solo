#!/bin/bash

TUBEGEN_EXE=$1
C3D_EXE=$2

# C3D is the Convert3D executable, which is a command-line medical image processing tool
# that ships with ITK-SNAP. Convert3D can also be downloaded on its own.
# -Main webpage: http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Convert3D
# -Download: http://www.itksnap.org/pmwiki/pmwiki.php?n=Downloads.C3D
# -Documentation: http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Documentation

# Create synthetic images of straight vessels of varying radii, defined here in mm:
declare -a RADII_MM=(0.2 0.6 1.0 1.4 1.8 2.2 2.6 3.0 3.4 3.8 4.2 4.6)

# Create images using different voxel spacings, defined here in mm:
declare -a VOXEL_SPACINGS=(0.40)

# Note: The rasterized vessel images will have exactly the radii given above.
# This is because of the way in which the both the vessel radii and the reference
# image size, spacing, and origin are defined. This allows us to construct
# unit tests of the "approximate vessel diamter" algorithm.

SMOOTHING_STDEV=0 # No smoothing
BG_INTENSITY=-1000 # Approximately air in a CT
LUMEN_INTENSITY=380 # About the intensity of a vessel with contrast in a CTA
WALL_INTENSITY=0 # No wall
WALL_THICKNESS=0 # No wall

OUT_DIR=straight_vessels
mkdir -p ${OUT_DIR}

RADII_CSV=${OUT_DIR}/measures.csv
rm -f ${RADII_CSV}

echo "spacing (mm/vox), true radius (mm), true diameter (mm)" >> ${RADII_CSV}

float_scale=3 # Decimals of precision

for spacing in ${VOXEL_SPACINGS[@]};
do
    echo -e "spacing = ${spacing} (mm/vox)"

    # Create reference space for the rasterized vessel images at this voxel spacing
    REF_IMAGE=${OUT_DIR}/refspace.nii.gz

    origin=$( bc <<< "scale=${float_scale}; 0.5 * 256 * ${spacing}" )
    origin=$( printf '%*.*f' 0 "${float_scale}" "$origin" )

    ${C3D_EXE} \
        -create \
            256x256x256vox \
            ${spacing}x${spacing}x${spacing}mm \
        -origin -${origin}x-${origin}x0.0mm \
        -o ${REF_IMAGE}

    for radius in ${RADII_MM[@]};
    do
        diameter=$( bc <<< "scale=${float_scale}; 2 * ${radius}" )
        diameter=$( printf '%*.*f' 0 "${float_scale}" "$diameter" )

        length=$( bc <<< "scale=${float_scale}; 256 * ${spacing}" )
        length=$( printf '%*.*f' 0 "${float_scale}" "$length" )

        echo -e "\tradius = ${radius} (mm); diameter = ${diameter} (mm)"
        echo "${spacing}, ${radius}, ${diameter}" >> ${RADII_CSV}

        OUT_NAME=vessel-radius_${radius}-spacing_${spacing}

        ${TUBEGEN_EXE} \
            --useLine \
            --lineStartPoint 0.0 0.0 0.0 \
            --lineEndPoint 0.0 0.0 ${length} \
            --startLumenRadius ${radius} \
            --endLumenRadius ${radius} \
            --wallThickness ${WALL_THICKNESS} \
            --smoothing ${SMOOTHING_STDEV} \
            --backgroundIntensity ${BG_INTENSITY} \
            --lumenIntensity ${LUMEN_INTENSITY} \
            --refImage ${REF_IMAGE} \
            --spacing ${spacing} ${spacing} ${spacing} \
            --outImage ${OUT_DIR}/${OUT_NAME}.nii.gz
    done
done
