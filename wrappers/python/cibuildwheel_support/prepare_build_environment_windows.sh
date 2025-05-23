#! /bin/bash

set -e
set -x

if [ "$ACCELERATOR" == "cu118" ]; then
    curl --netrc-optional -L -nv -o cuda.exe https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_522.06_windows.exe
    ./cuda.exe -s nvcc_11.8 nvrtc_11.8 nvrtc_dev_11.8 cudart_11.8 cufft_11.8 cufft_dev_11.8 cuda_profiler_api_11.8
    rm cuda.exe
    # Move CUDA folder to a path without spaces
    mv "/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v11.8" /c/CUDA
    export CUDA_PATH="/c/CUDA"
elif [ "$ACCELERATOR" == "cu124" ]; then
    curl --netrc-optional -L -nv -o cuda.exe https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda_12.4.0_551.61_windows.exe
    ./cuda.exe -s nvcc_12.4 nvrtc_12.4 nvrtc_dev_12.4 cudart_12.4 cufft_12.4 cufft_dev_12.4 cuda_profiler_api_12.4
    rm cuda.exe
    # Move CUDA folder to a path without spaces
    mv "/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.4" /c/CUDA
    export CUDA_PATH="/c/CUDA"
elif [ "$ACCELERATOR" == "cu126" ]; then
    curl --netrc-optional -L -nv -o cuda.exe https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda_12.6.0_560.76_windows.exe
    ./cuda.exe -s nvcc_12.6 nvrtc_12.6 nvrtc_dev_12.6 cudart_12.6 cufft_12.6 cufft_dev_12.6 cuda_profiler_api_12.6
    rm cuda.exe
    # Move CUDA folder to a path without spaces
    mv "/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.6" /c/CUDA
    export CUDA_PATH="/c/CUDA"
elif [ "$ACCELERATOR" == "cu128" ]; then
    curl --netrc-optional -L -nv -o cuda.exe https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda_12.8.1_572.61_windows.exe
    ./cuda.exe -s nvcc_12.8 nvrtc_12.8 nvrtc_dev_12.8 cudart_12.8 cufft_12.8 cufft_dev_12.8 cuda_profiler_api_12.8
    rm cuda.exe
    # Move CUDA folder to a path without spaces
    mv "/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8" /c/CUDA
    export CUDA_PATH="/c/CUDA"
elif [ "$ACCELERATOR" == "hip" ]; then
    curl.exe --output HIP.exe --url https://download.amd.com/developer/eula/rocm-hub/AMD-Software-PRO-Edition-24.Q3-Win10-Win11-For-HIP.exe
    ./HIP.exe -install
    rm HIP.exe
fi

# Download and extract OpenCL
curl --netrc-optional -L -nv -o OpenCL-SDK.zip https://github.com/KhronosGroup/OpenCL-SDK/releases/download/v2024.10.24/OpenCL-SDK-v2024.10.24-Win-x64.zip
unzip OpenCL-SDK.zip
OPENCL_PATH="$(pwd)/OpenCL-SDK-v2024.10.24-Win-x64"


# Configure build with Cmake
mkdir -p build
mkdir -p openmm-install
cd build
cmake -G "NMake Makefiles JOM" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=openmm-install \
    -DCMAKE_PREFIX_PATH="openmm-install;C:\Program Files\AMD\ROCm\6.1" \
    -DCMAKE_CXX_COMPILER=cl.exe \
    -DCMAKE_C_COMPILER=cl.exe \
    -DOPENCL_INCLUDE_DIR="${OPENCL_PATH}/include" \
    -DOPENCL_LIBRARY="${OPENCL_PATH}/lib/OpenCL.lib" \
    -DHIP_PLATFORM=amd \
    ..

# Build OpenMM
jom -j 4 install
jom -j 4 PythonInstall

cd ..

cp -r build/python/* wrappers/python/
cp -r build/openmm-install/include wrappers/python/openmm/
cp -r build/openmm-install/lib wrappers/python/openmm/

cp -r wrappers/python/tests/systems .

ls -la ./systems/