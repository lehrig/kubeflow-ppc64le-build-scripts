#!/usr/bin/env bash

VERSION="v1beta1"
CMD_PREFIX="cmd"
TAG="latest"

# Suggestion images

echo -e "\nBuilding hyperopt suggestion...\n"
docker build -t "suggestion-hyperopt:${TAG}" -f ${CMD_PREFIX}/suggestion/hyperopt/${VERSION}/Dockerfile .

echo -e "\nBuilding hyperband suggestion...\n"
docker build -t "suggestion-hyperband:${TAG}" -f ${CMD_PREFIX}/suggestion/hyperband/${VERSION}/Dockerfile .

echo -e "\nBuilding skopt suggestion...\n"
docker build -t "suggestion-skopt:${TAG}" -f ${CMD_PREFIX}/suggestion/skopt/${VERSION}/Dockerfile .

echo -e "\nBuilding goptuna suggestion...\n"
docker build -t "suggestion-goptuna:${TAG}" -f ${CMD_PREFIX}/suggestion/goptuna/${VERSION}/Dockerfile .

echo -e "\nBuilding optuna suggestion...\n"
docker build -t "suggestion-optuna:${TAG}" -f ${CMD_PREFIX}/suggestion/optuna/${VERSION}/Dockerfile .

#echo -e "\nBuilding ENAS suggestion...\n"
#docker build -t "suggestion-enas:${TAG}" -f ${CMD_PREFIX}/suggestion/nas/enas/${VERSION}/Dockerfile .

echo -e "\nBuilding DARTS suggestion...\n"
docker build -t "suggestion-darts:${TAG}" -f ${CMD_PREFIX}/suggestion/nas/darts/${VERSION}/Dockerfile .

echo -e "\nBuilding PBT suggestion...\n"
docker build -t "suggestion-pbt:${TAG}" -f ${CMD_PREFIX}/suggestion/pbt/${VERSION}/Dockerfile .

echo -e "\nAll Katib suggestion images with ${TAG} tag have been built successfully!\n"

