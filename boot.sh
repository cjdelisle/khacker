#!/bin/sh -x
. ./common.sh

id | grep -q root || die "would work better if you were root";

if [ "x${ARCH}" = "xamd64" ]; then
    KVM=qemu-system-x86_64
elif [ "x${ARCH}" = "xi386" ]; then
    KVM=qemu-system-i386
else
    die "cannot find kvm for ${ARCH}";
fi

[ -e ./shared ] || mkdir ./shared || die "could not create shared directory";

$KVM \
  -enable-kvm \
  -kernel ./linux/linux*/arch/x86/boot/bzImage \
  -drive file=${img},if=virtio \
  -net none \
  -append 'root=/dev/vda' \
  -chardev stdio,id=stdio,mux=on,signal=off \
  -device virtio-serial-pci \
  -device virtconsole,chardev=stdio \
  -mon chardev=stdio \
  -fsdev local,id=fs1,path=./shared,security_model=none \
  -device virtio-9p-pci,fsdev=fs1,mount_tag=shared

#  -display none \
# console=hvc0
