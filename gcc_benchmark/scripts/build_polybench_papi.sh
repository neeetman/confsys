#!/usr/bin/env bash

POLYBENCH_INSTALL_PREFIX=/usr/local
POLYBENCH_DIR=${POLYBENCH_INSTALL_PREFIX}/polybench

PAPI_BUILD_DIR=/tmp/papi-build
PAPI_DIR=/usr/local/papi

# Install polybench
wget -O polybench-c-4.2.1-beta.tar.gz "https://jaist.dl.sourceforge.net/project/polybench/polybench-c-4.2.1-beta.tar.gz" && \
tar -zxvf polybench-c-4.2.1-beta.tar.gz -C $POLYBENCH_INSTALL_PREFIX && \
mv ${POLYBENCH_INSTALL_PREFIX}/polybench-c-4.2.1-beta $POLYBENCH_DIR && \
rm polybench-c-4.2.1-beta.tar.gz


# Install PAPI
mkdir -p $PAPI_BUILD_DIR

git clone "https://bitbucket.org/icl/papi.git" $PAPI_BUILD_DIR 

pushd ${PAPI_BUILD_DIR}/src
./configure --prefix=$PAPI_DIR && \
make && make install
popd

rm -rf $PAPI_BUILD_DIR

# Edit environment variables
cat << EOF >> /etc/profile

# POLYBENCH
export POLYBENCH_DIR=$POLYBENCH_DIR

# PAPI
export PAPI_DIR=$PAPI_DIR
export PATH=\${PAPI_DIR}/bin:\$PATH
export LD_LIBRARY_PATH=\${PAPI_DIR}/lib:\$LD_LIBRARY_PATH

EOF
echo 'source /etc/profile' >> /root/.bashrc

# Enable PAPI envents
cat << EOF > ${POLYBENCH_DIR}/utilities/papi_counters.list
"PAPI_TOT_INS",
"PAPI_TOT_CYC",
EOF
