#!/bin/bash

DISP_TOOL=$1
LOG_DIR=$2
CONFIG_INI=$3
LAYOUT=$4
WI_DIR=$5
LCOR_COMP=$6
RCOR_COMP=$7
LCOR_LUM_SEG=$8
RCOR_LUM_SEG=$9
LCOR_WALL_SEG=${10}
RCOR_WALL_SEG=${11}
LCOR_INF_READ=${12}
RCOR_INF_READ=${13}
SERIES_CT_JSON=${14}

LCOR="LeftCoronary"
RCOR="RightCoronary"

export EVCFG=${CONFIG_INI}
export EV_INTERACTIVE_DISPLAY=1

mkdir -p ${LOG_DIR}

pushd ${WI_DIR}

    ${DISP_TOOL} \
        -L ${LOG_DIR} \
        -W . \
        -l ${LAYOUT} \
        -c ${LCOR}/${LCOR_COMP},${RCOR}/${RCOR_COMP} \
        -s ${LCOR}/${LCOR_LUM_SEG},${LCOR}/${LCOR_WALL_SEG},${RCOR}/${RCOR_LUM_SEG},${RCOR}/${RCOR_WALL_SEG} \
        -p ${LCOR}/${LCOR_INF_READ},${RCOR}/${RCOR_INF_READ} \
        ${SERIES_CT_JSON}

popd
