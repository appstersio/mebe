#!/usr/bin/env bash

set -eux
set -o pipefail

TARGETDIR=../../../priv/static

tsc
mkdir -p ${TARGETDIR}
cp -r assets/ ${TARGETDIR}/assets
cp -r build/ ${TARGETDIR}/build
cp -r vendor/ ${TARGETDIR}/build/vendor
