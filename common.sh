#!/bin/sh
. ./config.sh
img=vmroot_${DIST}_${ARCH}.img
die() { echo "error $1"; exit 100; }
