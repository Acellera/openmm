#! /bin/bash

set -e
set -x

# Install dependencies with yum
dnf install -y doxygen zip opencl-headers ocl-icd

if [ "$ACCELERATOR" == "cu118" ]; then
    # Install CUDA 11.8
    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo

    dnf install --setopt=obsoletes=0 -y \
        cuda-compiler-11-8-11.8.0-1 \
        cuda-libraries-11-8-11.8.0-1 \
        cuda-libraries-devel-11-8-11.8.0-1
        
    ln -s cuda-11.8 /usr/local/cuda

    export CUDA_HOME="/usr/local/cuda"
fi

if [ "$ACCELERATOR" == "cu124" ]; then
    # Install CUDA 12.4
    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo

    dnf install --setopt=obsoletes=0 -y \
        cuda-compiler-12-4-12.4.1-1 \
        cuda-libraries-12-4-12.4.1-1 \
        cuda-libraries-devel-12-4-12.4.1-1

    ln -s cuda-12.4 /usr/local/cuda

    export CUDA_HOME="/usr/local/cuda"
fi

if [ "$ACCELERATOR" == "cu126" ]; then
    # Install CUDA 12.6
    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo

    dnf install --setopt=obsoletes=0 -y \
        cuda-compiler-12-6-12.6.3-1 \
        cuda-libraries-12-6-12.6.3-1 \
        cuda-libraries-devel-12-6-12.6.3-1

    ln -s cuda-12.6 /usr/local/cuda

    export CUDA_HOME="/usr/local/cuda"
fi

if [ "$ACCELERATOR" == "hip" ]; then
    # Install HIP 6.2
    dnf install -y https://repo.radeon.com/amdgpu-install/6.2.2/el/8.10/amdgpu-install-6.2.60202-1.el8.noarch.rpm
    dnf install -y rocm-device-libs hip-devel hip-runtime-amd hipcc
fi

# Configure build with Cmake
mkdir -p build
mkdir -p openmm-install
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=openmm-install \
    -DCMAKE_CXX_FLAGS='-D_GLIBCXX_USE_CXX11_ABI=1' \
    -DOPENMM_BUILD_OPENCL_LIB=ON \
    -DOPENCL_INCLUDE_DIR=/usr/include/CL \
    -DOPENCL_LIBRARY=/usr/lib64/libOpenCL.so.1

# Build OpenMM
make -j4 install
make -j4 PythonInstall

cd ..

cp -r build/python/* wrappers/python/
cp -r build/openmm-install/include wrappers/python/openmm/
cp -r build/openmm-install/lib wrappers/python/openmm/
