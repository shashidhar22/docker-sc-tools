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

# Install UMAP
RUN LLVM_CONFIG=/usr/lib/llvm-11/bin/llvm-config pip3 install llvmlite
RUN pip3 install numpy
RUN pip3 install umap-learn

# Install FIt-SNE
RUN git clone --branch v1.2.1 https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install cellranger; Note: you might need a new cellranger download link everytime you build the image
RUN cd /opt/ && \
	wget -O cellranger-7.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-7.0.0.tar.gz?Expires=1653026224&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci03LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NTMwMjYyMjR9fX1dfQ__&Signature=PL6CqINXqz0ozj~1VVNH9UicEeMYUqzY9JZ2o8mW-oDWFxD-URlMvmjEe3cBd2WUV3hMN-x1oVVcprRpqc1hv9U59jaMm3HqUWtRS1nyc0t28CGS-s3fDQjyd7XJsIqTckCK88GAYlme12Y~rcU9CbfZpLvnySGHDQJZdiGsy-kp8prRU2nduNcS5cNPSJJNy9K-FFn-5meDM~23W57A31DALAQ19rgbbat4atpAvVs4Pjo9WdtjFQs9X2qeEyGgoT7hyv6rLEQKPN5Qg4SuxBORFb9J97T01R4HW3lbzREmC-4-Pj8FFsPkzx-hf85gmj51unZlOUb3pALCNgpv7Q__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" && \	
	tar -xzvf cellranger-7.0.0.tar.gz && \
	rm -f cellranger-7.0.0.tar.gz

# path
ENV PATH /opt/cellranger-7.0.0:$PATH

# Install bioconductor dependencies & suggests
RUN R --no-echo -e "install.packages('BiocManager')" && \
    R --no-echo -e "BiocManager::install(c('scuttle', 'scran', 'scater', 'DropletUtils', 'org.Hs.eg.db', 'phyloseq', 'org.Mm.eg.db', 'scDblFinder', 'batchelor', 'Biobase', 'BiocGenerics', 'DESeq2', 'DelayedArray', 'DelayedMatrixStats', 'GenomicRanges', 'glmGamPoi', 'IRanges', 'limma', 'MAST', 'Matrix.utils', 'multtest', 'rtracklayer', 'S4Vectors', 'SingleCellExperiment', 'SummarizedExperiment'))" && \
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

# Install DeepTCR, tcrDist, Trex, and clusTCR
RUN pip3 install --upgrade pip && \
    pip3 install DeepTCR 
RUN pip3 install tcrdist3
RUN conda install clustcr-gpu -c svalkiers -c bioconda -c pytorch -c conda-forge 