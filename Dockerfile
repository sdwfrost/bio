FROM sdwfrost/polyglot-base:latest

LABEL maintainer="Simon Frost <sdwfrost@gmail.com>"

USER root 

ENV DEBIAN_FRONTEND noninteractive

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
