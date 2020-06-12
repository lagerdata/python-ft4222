#!/bin/bash
set -e -u -x

if [ -z ${PYBIN+x} ]; then
    echo 'you have not supplied $PYBIN'
    exit 1
fi

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        #auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
        auditwheel repair "$wheel" -w /io/wheelhouse/
    fi
}

yum install -y gcc

cd /io

"${PYBIN}/pip" install --upgrade pip setuptools
"${PYBIN}/pip" install cython
"${PYBIN}/python" setup.py bdist_wheel --dist-dir /io/wheelhouse/
#"${PYBIN}/pip" wheel --no-deps -w /io/wheelhouse/ .

#repair_wheel /io/wheelhouse/*.whl

#"${PYBIN}/pip" install ft4222 --no-index -f /io/wheelhouse
#(cd "$HOME"; "${PYBIN}/python" -c "import ft4222")
