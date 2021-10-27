#!/bin/bash

set -e

# Check platform parameter
if [ $# -lt 1 ]; then
    echo "Please specify a platform"
    exit 1
fi
PLATFORM=`pwd`/$1
if [ ! -d $PLATFORM ]
then
    echo "Directory $PLATFORM does not exist."
    exit 1
fi

shift

HERE=`dirname $0`
HERE=`realpath $HERE`
source $HERE/settings.sh
source $PLATFORM/settings.sh


#echo "====> Loading modules"
#module swap PrgEnv-intel PrgEnv-gnu
#module load gcc/9.3.0

SKIP_SPACK=0 # skip installation of spack
SKIP_MOCHI=0 # skip installation of mochi repo
SKIP_YOKAN=0 # skip installation of yokan

while [[ $# -gt 0 ]]
do
    case $1 in
    --skip-spack)
        SKIP_SPACK=1
        shift
        ;;
    --skip-mochi)
        SKIP_MOCHI=1
        shift
        ;;
    --skip-yokan)
        SKIP_YOKAN=1
        shift
        ;;
    *)
        echo "====> ERROR: unkwown argument $1"
        exit -1
        ;;
    esac
done

function install_spack {
    # Checking if spack is already there
    if [ -d $YOKAN_EXP_SPACK_LOCATION ];
    then
        echo "====> ERROR: spack is already installed in $YOKAN_EXP_SPACK_LOCATION," \
             "please remove it or use --skip-spack"
        exit -1
    fi
    # Cloning spack and getting the correct release tag
    echo "====> Cloning Spack"
    git clone https://github.com/spack/spack.git $YOKAN_EXP_SPACK_LOCATION
    if [ -z "$YOKAN_EXP_SPACK_VERSION" ]; then
        echo "====> Using develop version of Spack"
    else
        echo "====> Using spack version/tag/commit $YOKAN_EXP_SPACK_VERSION"
        pushd $YOKAN_EXP_SPACK_LOCATION
        git checkout $YOKAN_EXP_SPACK_VERSION
        popd
    fi
}

function setup_spack {
    echo "====> Setting up spack"
    . $YOKAN_EXP_SPACK_LOCATION/share/spack/setup-env.sh
}

function install_mochi {
    if [ -d $YOKAN_EXP_MOCHI_LOCATION ]; then
        echo "====> ERROR: Mochi already installed in $YOKAN_EXP_MOCHI_LOCATION," \
             " please remove it or use --skip-mochi"
        exit -1
    fi
    echo "====> Cloning Mochi namespace"
    git clone https://github.com/mochi-hpc/mochi-spack-packages.git $YOKAN_EXP_MOCHI_LOCATION
    if [ -z "$YOKAN_EXP_MOCHI_COMMIT" ]; then
        echo "====> Using current commit of mochi-spack-packages"
    else
        echo "====> Using mochi-spack-packages at commit $YOKAN_EXP_MOCHI_COMMIT"
        pushd $YOKAN_EXP_MOCHI_LOCATION
        git checkout $YOKAN_EXP_MOCHI_COMMIT
        popd
    fi
}

function install_yokan {
    echo "====> Setting up Yokan environment"
    spack env create $YOKAN_EXP_SPACK_ENV $PLATFORM/spack.yaml
    echo "====> Activating environment"
    spack env activate $YOKAN_EXP_SPACK_ENV
    echo "====> Adding Mochi namespace"
    spack repo add --scope env:$YOKAN_EXP_SPACK_ENV $YOKAN_EXP_MOCHI_LOCATION
    echo "====> Installing"
    spack install
    spack env deactivate
}

if [ "$SKIP_SPACK" -eq "0" ]; then
    install_spack
fi

if [ "$SKIP_MOCHI" -eq "0" ]; then
    install_mochi
fi

setup_spack

if [ "$SKIP_YOKAN" -eq "0" ]; then
    install_yokan
fi
