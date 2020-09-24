#! /bin/sh

NCORES=$1

cd cmake
./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL=OFF
make -j${NCORES}
cd ..
