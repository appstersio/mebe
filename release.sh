#!/usr/bin/env bash

set -eux
set -o pipefail

CURRENT_DIR=$(pwd)
FRONTEND_PATH='lib/web/frontend'

cd ${FRONTEND_PATH}

bsb -make-world
NODE_ENV=production node fuse build

cd ${CURRENT_DIR}

# Force new statics to be picked up
MIX_ENV=prod mix compile --force

MIX_ENV=prod mix release --env=prod
