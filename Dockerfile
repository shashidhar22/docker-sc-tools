# Dockerfile for the Seurat 4.1.0
FROM rocker/r-ubuntu:22.04

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=TRUE


# Setup conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh && \ 
    bash Miniconda3-py39_4.11.0-Linux-x86_64.sh -b -p /opt/conda


ENV PATH=/opt/conda/bin:$PATH
# Install Seurat's system dependencies
RUN apt-get update --fix-missing
RUN apt-get install -y \
    libhdf5-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libpng-dev \
    libboost-all-dev \
    libcairo2-dev \
    libxml2-dev \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    wget \
    git \
    libfftw3-dev \
    libgsl-dev \
    libgeos-dev \
    libfontconfig1-dev \
    libudunits2-dev \
    libgdal-dev \
    cmake   

RUN apt-get install -y llvm-11
RUN apt-get install -y pkg-config


# Install UMAP
RUN pip3 install --upgrade pip setuptools wheel
RUN LLVM_CONFIG=/usr/lib/llvm-11/bin/llvm-config pip3 install llvmlite
RUN pip3 install numpy
RUN pip3 install umap-learn
# RUN pip3 install git+https://github.com/sidhomj/DeepTCR.git



#Install ImmuneML
RUN pip3 install immuneML && \
    pip3 install --no-dependencies git+https://github.com/widmi/widis-lstm-tools && \
    pip3 install git+https://github.com/ml-jku/DeepRC



## Install compairr
RUN git clone https://github.com/uio-bmi/compairr.git && \
    cd compairr && \
    make install

#RUN pip3 install git+https://github.com/sidhomj/DeepTCR.git

# Install FIt-SNE
RUN git clone --branch v1.2.1 https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install cellranger; Note: you might need a new cellranger download link everytime you build the image
RUN cd /opt/ && \
	wget -O cellranger-7.1.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-7.1.0.tar.gz?Expires=1674554368&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci03LjEuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NzQ1NTQzNjh9fX1dfQ__&Signature=WrnxiybWMbSK-PMcZoGACr6gGr08~2LFlmpQLROpcrCBnjjSWeGGCYnu1O1FFKeMg9f1qpUhY1NuZLZwXoj9Siqgouo9OpeCINT0WUiXLxdKkjgSo59FPd0NFrKDvkn1hhosQfU2oLXeI33B9LqNl13himIW3wFH5DfrIDp4GviY4nRWQwXBf7nVip0jYt4OWsKoyKTW6~SH4byE4Tjx-p5-S4ceAm4ch0q0vpewC8PSXiqdTh3ppvGwycLw1f1KWB0eKPi81T2deeDylo6aJ7sarQvIta6eehNuu10jg6~FLwXr0~z0f3eyZXzg1m5AV1UM3nhYDcKeVQdMkEL5tQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" && \
	tar -xzvf cellranger-7.1.0.tar.gz && \
	rm -f cellranger-7.1.0.tar.gz

# path
ENV PATH /opt/cellranger-7.1.0:$PATH

# Install bioconductor dependencies & suggests
RUN R --no-echo -e "install.packages('BiocManager')" && \
    R --no-echo -e "BiocManager::install(c('scuttle', 'scran', 'scater', 'biomaRt', 'ensembldb', 'AnnotationHub', 'ComplexHeatmap', 'HDF5Array', 'DropletUtils', 'org.Hs.eg.db', 'phyloseq', 'org.Mm.eg.db', 'scDblFinder', 'batchelor', 'Biobase', 'BiocGenerics', 'DESeq2', 'DelayedArray', 'DelayedMatrixStats', 'GenomicRanges', 'glmGamPoi', 'IRanges', 'limma', 'MAST', 'Matrix.utils', 'multtest', 'rtracklayer', 'S4Vectors', 'SingleCellExperiment', 'SummarizedExperiment'))" && \
    R --no-echo -e "install.packages(c('pheatmap', 'shiny', 'spdep', 'rgeos', 'VGAM', 'R.utils', 'metap', 'Rfast2', 'ape', 'enrichR', 'mixtools', 'tidyverse', 'argparse', 'jsonlite', 'uwot', 'optparse', 'systemfonts'))" && \
    R --no-echo -e "install.packages(c('keras', 'hdf5r', 'remotes', 'Seurat', 'devtools', 'robustbase', 'ggrastr', 'terra', 'lme4'))" && \
    R --no-echo -e "remotes::install_github('mojaveazure/seurat-disk')" && \
    R --no-echo -e "remotes::install_github('shashidhar22/LymphoSeq2', build_vigentte = TRUE)" && \
    R --no-echo -e "install.packages(c('alakazam', 'ggparty'))" && \
    R --no-echo -e "remotes::install_github('carmonalab/scGate')" && \
    R --no-echo -e "remotes::install_github('carmonalab/ProjecTILs')" && \
    R --no-echo -e "remotes::install_github('cole-trapnell-lab/leidenbase')" && \
    R --no-echo -e "remotes::install_github('cole-trapnell-lab/monocle3')" && \
    R --no-echo -e "remotes::install_github('cole-trapnell-lab/garnett', ref='monocle3')" && \
    R --no-echo -e "remotes::install_github('ncborcherding/scRepertoire@dev')" && \
    R --no-echo -e "BiocManager::install('harmony')" && \
    R --no-echo -e "install.packages('tidyHeatmap')"

# Install GLIPH2
RUN cd /opt/ && \
    wget http://50.255.35.37:8080/downloads/irtools.centos && \
    chmod a+x irtools.centos

ENV PATH /opt/irtools.centos:$PATH

# Install tcrdist3
RUN pip3 install python-levenshtein==0.12.0 && \
    pip3 install pytest && \
    pip3 install jedi==0.17.2 && \
    pip3 install ipython==7.18.1 && \
    pip3 install git+https://github.com/kmayerb/tcrdist3.git@0.2.2 && \
    pip3 install requests

# Load conda env and install Conga. clustcr, scanpy ecosystem tools, clusTCR and OLGA
RUN conda init bash && \
    . /root/.bashrc && \
    conda activate && \
    conda install mamba -n base -c conda-forge && \
    mamba init bash && \
    . /root/.bashrc && \
    mamba create -n conga_new_env ipython python=3.6 && \
    mamba activate conga_new_env && \
    mamba install seaborn scikit-learn statsmodels numba pytables && \
    mamba install -c conda-forge python-igraph leidenalg louvain notebook && \
    mamba install -c intel tbb && \
    pip install scanpy && \
    pip install fastcluster && \ 
    mamba install pyyaml && \
    mamba install -c conda-forge imagemagick && \ 
    git clone https://github.com/phbradley/conga.git && cd conga/tcrdist_cpp && make && cd .. && pip install -e . && \
    mamba install -c anaconda pandas && \
    mamba install -c conda-forge "networkx>=2.5" && \
    mamba install clustcr -c svalkiers -c bioconda -c pytorch -c conda-forge && \
    pip install -U scvelo && \
    pip install scirpy && \
    pip install olga && \
    mamba install -c anaconda pandas && \
    mamba install -c conda-forge "networkx>=2.5" && \
    mamba install clustcr -c svalkiers -c bioconda -c pytorch -c conda-forge

