#!/bin/sh

cat >> Dockerfile <<'EOF'

FROM quay.io/ibm/kubeflow-notebook-image-ppc64le:jenkins-base-py3.7


# prepare for kubeflow
USER root

RUN echo "$NB_USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$NB_USER

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    g++ \
    gnupg-agent \
    libssl-dev \
    libffi-dev \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    gfortran \
    vim-tiny \
    git \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    software-properties-common \
    tzdata \
    unzip \
    nano-tiny \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=ppc64el] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt-get update && apt-get install -yq --no-install-recommends \
    docker-ce \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# prepare python
USER $NB_UID
WORKDIR $HOME
ENV IBM_POWERAI_LICENSE_ACCEPT=yes
RUN conda config --system --set channel_priority false && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --prepend channels mgiessing && \
    conda config --system --prepend channels https://opence.mit.edu/ && \
    conda config --system --prepend channels https://repo.anaconda.com/pkgs/main && \
    conda install --quiet --yes \
    ##################
    # conda packages
    'gxx_linux-ppc64le' \
    'git' \
    && \
    ##################
    # Cleanup
    conda clean --all -f -y && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"


# prepare for go
USER root
WORKDIR /root
RUN wget https://go.dev/dl/go1.19.1.linux-ppc64le.tar.gz
RUN tar -C /usr/local -xzf go1.19.*
RUN rm -rf /Miniconda3* go.1.19*
ENV GOROOT=/usr/local/go \
    GOPATH=/usr/local/go/bin \
    PATH=/usr/local/go/bin:$PATH

# Fix permissions
USER root
RUN fix-permissions /usr/local/bin/

# Switch back to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME

CMD ["/bin/bash"]

EOF


sudo docker build --no-cache --build-arg VERSION=${RELEASE} -t quay.io/ibm/${IMAGE}:${RELEASE} -f Dockerfile .


set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
