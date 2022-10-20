#!/usr/bin/env bash
set -exo pipefail
[[ -z "${1}" ]] && echo "must provide the MUAF script as ARG1" && exit 1
SCRIPT_DIR="$(echo ${1} | rev | cut -d/ -f2-99 | rev)"
SCRIPT_NAME="$(echo ${1} | rev | cut -d/ -f1 | rev)"
cd "${SCRIPT_DIR}"
IFS=$'\n'
for MUAV in $(grep ^\\$ "${SCRIPT_NAME}"); do
    MUAV_NAME="$(echo ${MUAV} | awk '{print $1}' | sed 's/\$//g')"
    [[ -f "${MUAV_NAME}.png" ]] && MUAV_NAME="${MUAV_NAME}_alt"
    MUAV_VAL="$(echo ${MUAV} | awk '{print $2}')"
    echo -n "${MUAV_VAL}" | base64 --decode > "${MUAV_NAME}.png"
done