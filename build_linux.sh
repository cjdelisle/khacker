#!/bin/sh -x
. ./common.sh
KERNEL="`echo $KERNEL_URL | sed 's/.*\///'`";

if [ -e linux ]; then
    rm -rf ./linux || die "failed to remove linux";
fi
if [ -e bzImage ]; then
    rm ./bzImage || die "failed to remove bzImage";
fi

if [ ! -e dl ]; then
    mkdir dl || die "failed mkdir dl";
fi
if [ ! -e dl/$KERNEL ]; then
    wget -o dl/$KERNEL $KERNEL_URL || die "failed downloading kernel";
fi
mkdir linux || die "failed mkdir linux";
cd linux || die "failed cd linux";
tar -xf ../dl/$KERNEL

cd linux* || die "cd linux*"
make defconfig || die "make defconfig";
cat ../../kconfig | sed -n -e 's/^\([^#]*\)=[yn]$/\1/p' | while read x; do
    sed -i -e "/$x[ =]/d" ./.config || echo "$x";
done
cat ../../kconfig | grep -v '#' >> ./.config;
make || die "build linux"
