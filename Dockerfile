FROM jupyter/minimal-notebook:latest

LABEL maintainer="Simon Frost <sdwfrost@gmail.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -yq dist-upgrade\
    && apt-get install -yq \
    autoconf \
    automake \
    ant \
    apt-file \
    apt-utils \
    apt-transport-https \
    build-essential \
    bzip2 \
    ca-certificates \
    cmake \
    curl \
    gcc \
    gcc-multilib \
    g++ \
    g++-multilib \
    gfortran \
    gfortran-multilib \
    git \
    libboost-all-dev \
    m4 \
    openjdk-8-jre \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment

ENV SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV HOME=/home/$NB_USER

USER $NB_USER

# Conda executables

RUN conda install \
    hmmer samtools mafft fastp minimap2 fastqc picard -c bioconda

# Python libraries

# Git repos

RUN cd ${HOME} && \
    git clone https://github.com/cbg-ethz/ngshmmalign && \
    cd ngshmmalign && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=${HOME}/.local/ngshmmalign .. && \
    make && \
    make install && \
    cd ${HOME} && \
    rm -rf ngshmmalign

ENV PATH=${HOME}/.local/ngshmmalign/bin:$PATH

# Copy everything and fix permissions
USER root
RUN fix-permissions ${HOME} && \
    chown -R ${NB_USER}:users ${HOME}

USER $NB_USER
