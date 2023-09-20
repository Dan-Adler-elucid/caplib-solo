#!/bin/bash

disp_tool=$1

./disp.sh \
    ${disp_tool} \
    logs \
    /inst/EVServer-Release-HwOffS/config.ini \
    oblique \
    \"/inst/staging-b-1-dev3/AppData/Institutions/MUSC/Working\ Storage/wi_Emily_Jeffreys/S3_0008/wi-3784ff10\" \
    Emily.Jeffreys_20230918__composition.multi.nrrd \
    Emily.Jeffreys_20230918__composition.multi.nrrd \
    Emily.Jeffreys_20230918_lumenSegmentation.nrrd \
    Emily.Jeffreys_20230918_lumenSegmentation.nrrd \
    Emily.Jeffreys_20230918_wallSegmentation.nrrd \
    Emily.Jeffreys_20230918_wallSegmentation.nrrd \
    Emily.Jeffreys_20230918_inferred_readings.json \
    Emily.Jeffreys_20230918_inferred_readings.json \
    series_CT_0.json
