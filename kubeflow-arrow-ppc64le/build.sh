#!/bin/sh

##Build (py)arrow

sudo apt-get update -y && sudo apt-get install git ninja-build libjemalloc-dev libboost-dev \
                       libboost-filesystem-dev \
                       libboost-system-dev \
                       libboost-regex-dev \
                       python-dev \
                       autoconf \
                       flex \
                       bison -y



git submodule init
git submodule update
export PARQUET_TEST_DATA="${PWD}/cpp/submodules/parquet-testing/data"
export ARROW_TEST_DATA="${PWD}/testing/data"
export ARROW_BUILD_TYPE=release
sudo export PYTHON_EXECUTABLE=$(which python3)



sed -i "s/benchmark=1.4.1/#benchmark=1.4.1/g" ci/conda_env_cpp.yml
sed -i "s/gtest=1.8.1/gtest/g" ci/conda_env_cpp.yml
sed -i "s/gmock>=1.8.1/gmock/g" ci/conda_env_cpp.yml
sed -i "s/numpy>=1.14/numpy==1.19.2/g" ci/conda_env_python.yml

conda create -y -n pyarrow-dev -c conda-forge \
    --file ci/conda_env_unix.yml \
    --file ci/conda_env_cpp.yml \
    --file ci/conda_env_python.yml \
    --file ci/conda_env_gandiva.yml \
    compilers \
    python=3.7 \
    pandas \
    git \
    make \
    cmake

/bin/bash -c "source activate pyarrow-dev && pip install Cython"

export ARROW_HOME=$CONDA_PREFIX

mkdir cpp/build

/bin/bash -c "source activate pyarrow-dev && cmake -GNinja -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DARROW_WITH_BZ2=ON \
      -DARROW_WITH_ZLIB=ON \
      -DARROW_WITH_ZSTD=ON \
      -DARROW_WITH_LZ4=ON \
      -DARROW_WITH_SNAPPY=ON \
      -DARROW_WITH_BROTLI=ON \
      -DARROW_PARQUET=ON \
      -DARROW_PYTHON=ON \
      -DARROW_PLASMA=ON \
      -DARROW_BUILD_TESTS=ON \
      -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
      cpp"

/bin/bash -c "source activate pyarrow-dev && sudo ninja"
/bin/bash -c "source activate pyarrow-dev && sudo ninja install"



#Building pyarrow
export PYARROW_WITH_PARQUET=1
/bin/bash -c "source activate pyarrow-dev && sudo /opt/conda/bin/python3 python/setup.py build_ext --build-type=$ARROW_BUILD_TYPE --bundle-arrow-cpp bdist_wheel"
