#!/bin/bash

# IMPORTANT: for portability, all the paths should be absolute.
# To make a path relative to the folder containing the install.sh
# script, use $HERE.

YOKAN_EXP_SOURCE_PATH=$HERE/_src # where sources will be downloaded
YOKAN_EXP_PREFIX_PATH=$HERE/_sw  # where software will be installed

# override if you want to use your own spack
YOKAN_EXP_SPACK_LOCATION=$YOKAN_EXP_PREFIX_PATH/spack
# override if you want to use another tag/version/commit of spack
YOKAN_EXP_SPACK_VERSION=develop
# override if you have mochi packages installed somewhere else
YOKAN_EXP_MOCHI_LOCATION=$YOKAN_EXP_PREFIX_PATH/mochi-spack-packages
# override if you want to use another commit of the mochi packages
YOKAN_EXP_MOCHI_COMMIT=main
# override if you want to name the environment differently
YOKAN_EXP_SPACK_ENV=yokan-env
# Bedrock config
YOKAN_BEDROCK_CONFIG=$HERE/config.json
