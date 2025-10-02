#!/bin/bash

set +e

cd modules

gfortran -c strutils_module.f90

gfortran -c version_module.f90
gfortran -c interpret_module.f90 -I.

mv version_module.o ..
mv version_module.mod ..

mv interpret_module.o ..
mv interpret_module.mod ..

mv strutils_module.mod ..
mv strutils_module.o ..

cd ..

gfortran uranium.f90 version_module.o interpret_module.o strutils_module.o -o uranium

rm version_module.o version_module.mod
rm interpret_module.o interpret_module.mod
rm strutils_module.mod strutils_module.o