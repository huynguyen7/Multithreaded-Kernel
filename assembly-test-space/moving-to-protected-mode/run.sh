#!/bin/sh

# using -hda arg for hardrive mode.
qemu-system-x86_64 -nographic -hda ./boot.bin
#target remote | qemu-system-x86_64 -hda ./boot.bin -S -gdb stdio
