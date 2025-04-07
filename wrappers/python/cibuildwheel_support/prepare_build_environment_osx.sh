brew install doxygen

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=openmm-install
make -j4 install
make -j4 PythonInstall

cd ..

cp -r build/python/* wrappers/python/
cp -r build/openmm-install/include wrappers/python/
cp -r build/openmm-install/lib wrappers/python/openmm/
