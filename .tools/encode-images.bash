#!/usr/bin/env bash
set -exo pipefail
[[ -z "${1}" ]] && echo "must provide the MUAF script as ARG1" && exit 1
SCRIPT_DIR="$(echo ${1} | rev | cut -d/ -f2-99 | rev)"
SCRIPT_NAME="$(echo ${1} | rev | cut -d/ -f1 | rev)"
cd "${SCRIPT_DIR}"
for PNG in $(ls *.png); do
    MUAV_NAME="\$$(echo ${PNG} | cut -d. -f1)_image"
    MUAV_VAL="$(base64 $PNG)"
    grep "${MUAV_NAME} " "${SCRIPT_NAME}" && sed -i '' "/${MUAV_NAME}/d" "${SCRIPT_NAME}"
    echo -e "${MUAV_NAME} ${MUAV_VAL}\n$(cat ${SCRIPT_NAME})" > "${SCRIPT_NAME}"
done

# remove _alt from end of vars until boris adds || for ()
sed -i '' 's/_alt_image/_image/g' "${SCRIPT_NAME}"