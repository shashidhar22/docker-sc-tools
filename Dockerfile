# Dockerfile for the Seurat 4.1.0
FROM rocker/r-ver:4.1.0

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=FALSE

# Install Seurat's system dependencies
RUN apt-get update
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
    libgsl-dev

RUN apt-get install -y llvm-10

# Install UMAP
RUN LLVM_CONFIG=/usr/lib/llvm-10/bin/llvm-config pip3 install llvmlite
RUN pip3 install numpy
RUN pip3 install umap-learn

# Install FIt-SNE
RUN git clone --branch v1.2.1 https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install bioconductor dependencies & suggests
RUN R --no-echo --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --no-echo --no-restore --no-save -e "BiocManager::install(c('batchelor', 'Biobase', 'BiocGenerics', 'DESeq2', 'DelayedArray', 'DelayedMatrixStats', 'GenomicRanges', 'glmGamPoi', 'IRanges', 'limma', 'MAST', 'Matrix.utils', 'multtest', 'rtracklayer', 'S4Vectors', 'SingleCellExperiment', 'SummarizedExperiment'))"

# Install CRAN suggests
RUN R --no-echo --no-restore --no-save -e "install.packages(c('VGAM', 'R.utils', 'metap', 'Rfast2', 'ape', 'enrichR', 'mixtools'))"

# Install hdf5r
RUN R --no-echo --no-restore --no-save -e "install.packages('hdf5r')"

# Install OSAR packages
RUN R --no-echo --no-restore --no-save -e "install.packages(c('tidyverse', 'argparse', 'jsonlite', 'uwot', 'optparse'))"
RUN R --no-echo --no-restore --no-save -e "BiocManager::install(c('scuttle', 'scran', 'scater', 'DropletUtils', 'org.Hs.eg.db', 'org.Mm.eg.db', 'scDblFinder'))"

# Install Seurat
RUN R --no-echo --no-restore --no-save -e "install.packages('remotes')"
RUN R --no-echo --no-restore --no-save -e "install.packages('Seurat')"

# Install SeuratDisk
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('mojaveazure/seurat-disk')"

# Install Monocle3 and Garrnet
RUN R --no-echo --no-restore --no-save -e "install.packages('devtools')"
RUN R --no-echo --no-restore --no-save -e "devtools::install_github('cole-trapnell-lab/leidenbase')"
RUN R --no-echo --no-restore --no-save -e "devtools::install_github('cole-trapnell-lab/monocle3')"
RUN R --no-echo --no-restore --no-save -e "devtools::install_github('cole-trapnell-lab/garnett', ref='monocle3')"

# Install TCR tools
RUN R --no-echo --no-restore --no-save -e "devtools::install_github('ncborcherding/scRepertoire@dev')"
RUN R --no-echo --no-restore --no-save -e "devtools::install_github('WarrenLabFH/LymphoSeq2', ref='v1', build_vignette=FALSE)"