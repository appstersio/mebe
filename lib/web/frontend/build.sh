#!/usr/bin/env bash

set -eux
set -o pipefail

TARGETDIR=../../../priv/static

tsc
rm -rf ${TARGETDIR}
mkdir -p ${TARGETDIR}
cp -r assets ${TARGETDIR}
cp -r build ${TARGETDIR}
cp -r vendor ${TARGETDIR}/build
