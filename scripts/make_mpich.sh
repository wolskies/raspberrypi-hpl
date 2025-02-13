#!/bin/bash

. CONFIG

version=3.4.1
package=mpich

rm -rf ${package}-${version}
rm -rf ${WORKDIR}/${package}-${version}
sudo rm -rf /opt/${package}/${version}
wget http://www.mpich.org/static/downloads/${version}/${package}-${version}.tar.gz -O ${DOWNLOADS}/${package}-${version}.tar.gz

cd ${WORKDIR}
tar xfz ${DOWNLOADS}/${package}-${version}.tar.gz
cd ${package}-${version}

export CFLAGS=${COMMON_FLAGS}
export FCFLAGS=${COMMON_FLAGS}
export LDFLAGS=${COMMON_FLAGS}
export FFLAGS="-w -fallow-argument-mismatch -O2"

./configure --with-device=ch3 --prefix=/opt/${package}/${version}
make -j 3 
sudo make -j 3 install
