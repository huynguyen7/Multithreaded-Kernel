#!/bin/bash

# Use this file to build the project properly.
# since it has the necessary env variables that come with GCC-Cross Compiler.

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
make all
