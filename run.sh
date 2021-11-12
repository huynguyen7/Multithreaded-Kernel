#!/bin/sh

# using -hda arg for hardrive mode.

# x86_64 mode
#qemu-system-x86_64 -hda ./bin/os.bin

# x86_32 mode
qemu-system-i386 -hda ./bin/os.bin
