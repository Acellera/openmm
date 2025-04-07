#! /bin/bash

set -e
set -x

# Install dependencies with yum
dnf install -y doxygen zip opencl-headers ocl-icd

# # Install CUDA (nothing)

# # Install HIP
# export HIP_VERSION=6
# yum install -y epel-release
# yum install -y https://repo.radeon.com/amdgpu-install/6.2.2/el/8.10/amdgpu-install-6.2.60202-1.el8.noarch.rpm
# yum install -y rocm-device-libs hip-devel hip-runtime-amd hipcc

# Configure build with Cmake
mkdir -p build
mkdir -p openmm-install
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=openmm-install \
    -DCMAKE_CXX_FLAGS='-D_GLIBCXX_USE_CXX11_ABI=0' \
    -DOPENMM_BUILD_OPENCL_LIB=ON \
    -DOPENCL_INCLUDE_DIR=/usr/include/CL \
    -DOPENCL_LIBRARY=/usr/lib64/libOpenCL.so.1

# Build OpenMM
make -j4 install
make -j4 PythonInstall

cd ..

# Build wheel
export LD_LIBRARY_PATH=openmm-install/lib

cp -r build/python/* wrappers/python/
cp -r build/openmm-install/include wrappers/python/
cp -r build/openmm-install/lib wrappers/python/openmm/


