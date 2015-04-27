#!/bin/sh
. ./common.sh

echo "check for root";
id | grep -q root || die "would work better if you were root";

echo "check for image";
[ -e ${img} ] && die "${img} already exists, move it somewhere else first";

echo "clean";
if [ -e vmroot ]; then
    echo "remove vmroot";
    umount vmroot;
    rmdir vmroot || die "failed to remove vmroot";
fi
if [ -e ${img} ]; then
    echo "remove stale temp files";
    rm ./*.tmp || die "failed to remove temp files";
fi

echo "make dirs";
mkdir vmroot || die "failed to make vmroot dir";

echo "Building the disk image, copying 4G";
dd if=/dev/zero of=${img}.tmp bs=1M count=4096 &
DDPID=$!
sleep 1;
while kill -USR1 $DDPID; do sleep 5; done
mkfs.ext4 -F ${img}.tmp || die "failed mkfs.ext4 vmroot image";
mount -o loop ${img}.tmp vmroot || die "failed mount vmroot image";

echo "make the deb root";
debootstrap --no-check-gpg --arch=$ARCH --include=openssh-server --verbose ${DIST} vmroot || \
    die "debootstrap failed";

echo "make vm passwordless";
sed -i '/^root/ { s/:x:/::/ }' vmroot/etc/passwd || die "failed to update etc/passwd";

echo "add a getty on the virtio console";
echo 'V0:23:respawn:/sbin/getty 115200 hvc0' >> vmroot/etc/inittab || die "failed update inittab";

echo "Set to automatically bring up eth0 using DHCP"
printf '\nauto eth0\niface eth0 inet dhcp\n' >> vmroot/etc/network/interfaces || \
    die "failed update interfaces";

echo "Set up ssh pubkey for root in the VM";
mkdir vmroot/root/.ssh/ || die "failed to make vmroot/.ssh/ dir";
cat ~/.ssh/id_?sa.pub > vmroot/root/.ssh/authorized_keys || die "failed to make authorized_keys";

mkdir vmroot/shared || die "failed to make vmroot/shared";
sed -i -e 's/exit 0//' vmroot/etc/rc.local || die "failed to remove exit 0 from vmroot/rc.local";
echo "mount shared -t 9p /shared;" >> vmroot/etc/rc.local || die;
echo "/bin/bash /shared/init.sh;" >> vmroot/etc/rc.local || die;
echo "exit 0;" >> vmroot/etc/rc.local || die;

echo "cleanup";
umount vmroot || die "failed to unmount mount dir";
rmdir vmroot || die "failed to remove mount dir";

mv ./${img}.tmp ./${img} || die "failed to rename image";
