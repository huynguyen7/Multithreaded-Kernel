#!/bin/bash

# Use this file to build the project properly.
# since it has the necessary env variables that come with GCC-Cross Compiler.

mkdir -r build/idt
mkdir -r build/memory/heap
mkdir -r bin

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
make all
