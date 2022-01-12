#!/bin/sh

##Build ml-metadata

sudo apt-get update -y && sudo apt-get install openjdk-11-jdk build-essential -y 

#Python3.7 is default
conda install gxx_linux-ppc64le git numpy cmake -y 
conda install -c conda-forge bazel==4.1.0 -y
python setup.py bdist_wheel

curl -F package=@dist/$(ls dist) https://$TOKEN@push.fury.io/mgiessing/

#NOTE: OTHER PYTHON VERSIONS SEEM TO FAIL AT THE MOMENT, THEREFORE COMMENTED OUT!

# Create wheels for other python versions
#for PY_VER in 3.6 3.8 3.9
#do
#  conda create -n ${PY_VER} python=${PY_VER} -y
#  /bin/bash -c "source activate ${PY_VER} && conda install gxx_linux-ppc64le git numpy cmake -y"
#  /bin/bash -c "source activate ${PY_VER} && conda install -c conda-forge bazel==4.1.0 -y"
#  /bin/bash -c "source activate ${PY_VER} && python setup.py bdist_wheel"
#done

for WHEEL in `ls dist`
do
  curl -F package=@dist/$WHEEL https://$TOKEN@push.fury.io/mgiessing/
done
