# kHacker - Toolkit for developing kernel modules

Status: unmaintained

If you want to develop a kernel module, there's lots of documentation on how to get started,
even plenty of hello-world kernel modules available to play with, the problem is if you're
working on non-trivial size programs, you're going to face bugs and when you run into bugs,
you're going to have to try to figure out where the problem is.

Just `modprobe` the module into your workstation is certainly not a workable development
process so this set of tools will help you develop (and debug!) kernel modules.

## Get Started

This howto assumes you're using Ubuntu 14.04 (there are other operating systems?)

The first three steps will build the environment after that you should be able to get
started working on your own kernel development.

    # First install all the needed stuff
    sudo aptitude install `cat ./dependencies`

    # Then build the root fs image
    sudo build_debootstrap.sh

    # Then build the linux kernel
    sudo build_linux.sh

After this you will have a bzImage of the linux kernel and a vmroot image file of the root
fs, now with `sudo ./boot.sh` you should be able to boot your kernel whenever you want.

## init.sh

The guest vm will mount the directory called `shared`, this directory contains a script called
`init.sh` which will be run *inside of the vm* every time the vm starts up. If you develop a kernel
module, you can put it inside of shared and add a `modprobe` line to the `init.sh` file to load
it when the vm starts up.

## Debugging

The linux kernel is built using full debug symbols so you will be able to trace through it
using gdb, all you need to do is run `gdb ./linux/linux*/vmlinux -ex 'target remote localhost:1234'`
while your vm is running and your debugger will attach to the vm's kernel.

    user@toshitba:~/wrk/kcjdns$ gdb ./linux/linux*/vmlinux -ex 'target remote localhost:1234'
    GNU gdb (Ubuntu 7.7.1-0ubuntu5~14.04.2) 7.7.1
    Copyright (C) 2014 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
    and "show warranty" for details.
    This GDB was configured as "x86_64-linux-gnu".
    Type "show configuration" for configuration details.
    For bug reporting instructions, please see:
    <http://www.gnu.org/software/gdb/bugs/>.
    Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.
    For help, type "help".
    Type "apropos word" to search for commands related to "word"...
    Reading symbols from ./linux/linux-3.18.11/vmlinux...done.
    Remote debugging using localhost:1234
    atomic_read (v=<optimized out>) at ./arch/x86/include/asm/atomic.h:27
    27		return ACCESS_ONCE((v)->counter);
    (gdb) bt
    #0  atomic_read (v=<optimized out>) at ./arch/x86/include/asm/atomic.h:27
    #1  static_key_count (key=<optimized out>) at include/linux/jump_label.h:88
    #2  static_key_false (key=<optimized out>) at include/linux/jump_label.h:153
    #3  trace_cpu_idle_rcuidle (cpu_id=<optimized out>, state=<optimized out>) at include/trace/events/power.h:34
    #4  default_idle () at arch/x86/kernel/process.c:314
    #5  0xffffffff8100ca5a in arch_cpu_idle () at arch/x86/kernel/process.c:304
    #6  0xffffffff810817fc in cpuidle_idle_call () at kernel/sched/idle.c:120
    #7  cpu_idle_loop () at kernel/sched/idle.c:226
    #8  cpu_startup_entry (state=<optimized out>) at kernel/sched/idle.c:274
    #9  0xffffffff81824072 in rest_init () at init/main.c:418
    #10 0xffffffff81ef1fc6 in start_kernel () at init/main.c:680
    #11 0xffffffff81ef15ad in x86_64_start_reservations (real_mode_data=<optimized out>) at arch/x86/kernel/head64.c:193
    #12 0xffffffff81ef16a6 in x86_64_start_kernel (real_mode_data=0x13f90 <error: Cannot access memory at address 0x13f90>)
        at arch/x86/kernel/head64.c:182
    #13 0x0000000000000000 in ?? ()
    (gdb) 

## Quitting the emulator

In the emulator window you'll have a shell to the guest OS but there are some escape codes which
will break you out to the qemu control system, `ctrl+a h` will print help on this topic. If you're
anxious `ctrl+a x` quits the emulator.

Go make something awesome.
