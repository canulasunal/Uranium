#!/bin/sh

set -e

echo "Checking for GCC"
if command -v gcc; then
    sleep 0
else
    echo "Dependency Error: GCC not found on system."
fi

echo "Checking for Nim-Lang"
if command -v nim; then
    sleep 0
else
    echo "Dependency Error: Nim-Lang not found on system."
fi

cd source
nim c --opt:speed --passC:"-O3" uranium.nim
mv uranium ..
cd ..
mkdir bin
mv uranium bin

echo "Done. Results can be found in the ./bin directory"
