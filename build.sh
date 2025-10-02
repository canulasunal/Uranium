#!/bin/sh

set -e

if command -v nim; then
    echo "Nim Compiler Installed On System"
    echo "Proceeding to compile"
else
    echo "Error: The Nim language compiler is not installed on this system"
    echo "Error: Please install it from nim-lang.org to continue"
    exit
fi

cd source
nim c --opt:speed --passC:"-O3" uranium.nim
mv uranium ..
cd ..
mkdir bin
mv uranium bin

echo "Done. Results can be found in the ./bin directory"
