#!/bin/sh

##Build ml-metadata

sudo apt-get update -y && sudo apt-get install openjdk-11-jdk build-essential -y

#Python3.7 is default
conda install gxx_linux-ppc64le git numpy cmake -y
conda install -c conda-forge bazel==4.1.0 -y
./package_build/initialize.sh
python package_build/ml-pipelines-sdk/setup.py bdist_wheel
python package_build/tfx/setup.py bdist_wheel

# No alternative python versions needed as metadata creates a generic, version-independent py3 wheel
