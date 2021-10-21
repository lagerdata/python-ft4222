#!/bin/bash
set -e -u -x

PROJECT_DIR="$1"

# Put audited wheels here
WHEEL_DIR="$2"

# Put non-audited wheels here
TMP_WHEEL_DIR="$(mktemp -d)"

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pyproject-build" --wheel --outdir ${TMP_WHEEL_DIR} ${PROJECT_DIR}
done

# Bundle external shared libraries into the wheels
for whl in ${TMP_WHEEL_DIR}/*.whl; do
    if ! auditwheel show "$whl"; then
        echo "Skipping non-platform wheel $whl"
    else
        auditwheel repair "$whl" --plat "$PLAT" -w ${WHEEL_DIR}
    fi
done
