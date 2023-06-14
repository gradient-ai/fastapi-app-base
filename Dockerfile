#!/bin/bash

# Paperspace Dockerfile for FastAPI Deployment image
# Paperspace image is located in Docker Hub repository: paperspace/fastapi-app-base


# ==================================================================
# Initial setup
# ------------------------------------------------------------------

    # Ubuntu 20.04 as base image
    FROM ubuntu:20.04
    RUN yes| unminimize

    # Set ENV variables
    ENV LANG C.UTF-8
    ENV SHELL=/bin/bash
    ENV DEBIAN_FRONTEND=noninteractive

    ENV APT_INSTALL="apt-get install -y --no-install-recommends"
    ENV PIP_INSTALL="python3 -m pip --no-cache-dir install --upgrade"


# ==================================================================
# Tools
# ------------------------------------------------------------------

    RUN apt-get update && \
        $APT_INSTALL \
        apt-utils \
        gcc \
        make \
        pkg-config \
        apt-transport-https \
        build-essential \
        ca-certificates \
        wget \
        rsync \
        git \
        vim \
        mlocate \
        libssl-dev \
        curl \
        openssh-client \
        unzip \
        unrar \
        zip \
        csvkit \
        iputils-ping \
        sudo \
        ffmpeg \
        libsm6 \
        libxext6 \
        libboost-all-dev \
        cifs-utils \
        software-properties-common


# ==================================================================
# Python
# ------------------------------------------------------------------

    #Based on https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa

    # Adding repository for python3.10
    RUN add-apt-repository ppa:deadsnakes/ppa -y && \

    # Installing python3.10
        $APT_INSTALL \
        python3.10 \
        python3.10-dev \
        python3.10-venv \
        python3-distutils-extra

    # Add symlink so python and python3 commands use same python3.10 executable
    RUN ln -s /usr/bin/python3.10 /usr/local/bin/python3 && \
        ln -s /usr/bin/python3.10 /usr/local/bin/python

    # Installing pip
    RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
    ENV PATH=$PATH:/root/.local/bin


# ==================================================================
# Installing CUDA packages (CUDA Toolkit 11.6.2 & CUDNN 8.4.1)
# ------------------------------------------------------------------

    # Based on https://developer.nvidia.com/cuda-toolkit-archive
    # Based on https://developer.nvidia.com/rdp/cudnn-archive
    # Based on https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#package-manager-ubuntu-install

    # Installing CUDA Toolkit
    RUN wget https://developer.download.nvidia.com/compute/cuda/11.6.2/local_installers/cuda_11.6.2_510.47.03_linux.run && \
        bash cuda_11.6.2_510.47.03_linux.run --silent --toolkit && \
        rm cuda_11.6.2_510.47.03_linux.run
    ENV PATH=$PATH:/usr/local/cuda-11.6/bin
    ENV LD_LIBRARY_PATH=/usr/local/cuda-11.6/lib64

    # Installing CUDNN
    RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
        mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
        apt-get install dirmngr -y && \
        apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
        add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" && \
        apt-get update && \
        apt-get install libcudnn8=8.4.1.*-1+cuda11.6 -y && \
        apt-get install libcudnn8-dev=8.4.1.*-1+cuda11.6 -y && \
        rm /etc/apt/preferences.d/cuda-repository-pin-600


# ==================================================================
# Additional Python Packages
# ------------------------------------------------------------------

    RUN $PIP_INSTALL \
        fastapi==0.97.0 \
        uvicorn==0.19.0
