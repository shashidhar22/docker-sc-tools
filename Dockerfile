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
    libxml2-dev \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    wget \
    git \
    libfftw3-dev \
    libgsl-dev \
    libgeos-dev \
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
	wget -O cellranger-7.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-7.0.0.tar.gz?Expires=1654153315&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci03LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NTQxNTMzMTV9fX1dfQ__&Signature=R3cAux0zkPdsHlNgFCEOPnEwwY4sCFGS6ba4TqGN80EOX71CKWRW-JSVVIGKQBXbxzUaXu-ARh2T~zdX53SbVacm6eUFEgQ4ayhXPwGmo1PXFfrx5g4dM1t7iW7VLgU1O7NTCd5LogjCR4A7XcrgJfK4rPyv4DPWick3kTu3mgLNpY-g9L~DJqliecldJuxFW5jT07CFpR2V9JUxWtDQwRAJmRkSdPfAMZqAYIOnT99OOby7-eLrxhTWKNF9T3dx8sETNzV6-npoK~8DQc57FXY9VD9M1Kvzz5gV0GwjTFHrVeZNFRF0hr8rc-Y0bp3rz2iKlcQ4tSanReorh3m-NQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" && \	
	tar -xzvf cellranger-7.0.0.tar.gz && \
	rm -f cellranger-7.0.0.tar.gz

# path
ENV PATH /opt/cellranger-7.0.0:$PATH

# Install bioconductor dependencies & suggests
RUN R --no-echo -e "install.packages('BiocManager')" && \
    R --no-echo -e "BiocManager::install(c('scuttle', 'scran', 'scater',  'ComplexHeatmap', 'DropletUtils', 'org.Hs.eg.db', 'phyloseq', 'org.Mm.eg.db', 'scDblFinder', 'batchelor', 'Biobase', 'BiocGenerics', 'DESeq2', 'DelayedArray', 'DelayedMatrixStats', 'GenomicRanges', 'glmGamPoi', 'IRanges', 'limma', 'MAST', 'Matrix.utils', 'multtest', 'rtracklayer', 'S4Vectors', 'SingleCellExperiment', 'SummarizedExperiment'))" && \
    R --no-echo -e "install.packages(c('shiny', 'spdep', 'rgeos', 'VGAM', 'R.utils', 'metap', 'Rfast2', 'ape', 'enrichR', 'mixtools', 'tidyverse', 'argparse', 'jsonlite', 'uwot', 'optparse'))" && \
    R --no-echo -e "install.packages(c('keras', 'hdf5r', 'remotes', 'Seurat', 'devtools', 'robustbase'))" && \
    R --no-echo -e "remotes::install_github('mojaveazure/seurat-disk')" && \
    R --no-echo -e "devtools::install_github('cole-trapnell-lab/leidenbase')" && \
    R --no-echo -e "devtools::install_github('cole-trapnell-lab/monocle3')" && \
    R --no-echo -e "devtools::install_github('cole-trapnell-lab/garnett', ref='monocle3')" && \
    R --no-echo -e "devtools::install_github('ncborcherding/scRepertoire@dev')" && \
    R --no-echo -e "devtools::install_github('adw96/breakaway')" && \
    R --no-echo -e "devtools::install_github('WarrenLabFH/LymphoSeq2', ref='v1', build_vignette=FALSE)" && \
    R --no-echo -e "devtools::install_github('ncborcherding/Trex')"

# Install GLIPH2
RUN cd /opt/ && \
    wget http://50.255.35.37:8080/downloads/irtools.centos && \
    chmod a+x irtools.centos

ENV PATH /opt/irtools.centos:$PATH

