#!/bin/sh

##Build tf-transform

sudo apt-get update -y && sudo apt-get install openjdk-11-jdk build-essential -y

#Python3.7 is default
conda install gxx_linux-ppc64le git numpy cmake -y
conda install -c conda-forge bazel==4.1.0 -y
python setup.py bdist_wheel
