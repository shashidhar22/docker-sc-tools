FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TrimGaloreVersion 0.6.5
ENV BedToolsVersion=2.27.1
ENV BamToolsVersion=2.4.0
ENV SamToolsVersion=1.9
ENV CutAdaptVersion=1.18

RUN apt-get update       && \
    apt-get install -y      \
        wget                \
        bc                  \
        datamash            \
        curl                \
        grep                \
        build-essential     \
        zip                 \
        unzip               \
        python3-pip         \
        python3        \
        git                 \
        zlib1g              \
        pigz                \
        libpcre2-dev        \
        r-base              \
        hdf5-tools          \
        libhdf5-dev         \ 
        libhdf5-serial-dev  \
        libopenblas-dev     \
        openjdk-8-jre-headless && \
    ln -s /usr/bin/python3 /usr/local/bin/python  && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
    
ENV PATH=$PATH:/opt/conda/bin
RUN conda config --add channels bioconda && \
    conda upgrade conda

RUN pip3 install --upgrade pip

RUN pip3 install \
    numpy \
    scipy \
    cutadapt \
    biopython \
    pysam \
    tensorflow 

RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip -O fastqc.zip && \
    unzip fastqc.zip -d /usr/local/ && \
    rm fastqc.zip && \
    ln -s /usr/local/FastQC/fastqc /usr/local/bin/

RUN wget https://github.com/FelixKrueger/TrimGalore/archive/refs/tags/${TrimGaloreVersion}.tar.gz -O TrimGalore.tar.gz && \
    tar xvzf TrimGalore.tar.gz -C /usr/local/ && \
    rm TrimGalore.tar.gz && \
    ln -s /usr/local/TrimGalore-${TrimGaloreVersion}/trim_galore /usr/local/bin/

RUN conda install bedtools=${BedToolsVersion} && \
    conda install bamtools=${BamToolsVersion} && \
    conda install samtools=${SamToolsVersion} 

RUN git clone https://github.com/andrewhill157/barcodeutils.git && \
    cd barcodeutils/ && \
    python setup.py install

RUN Rscript -e "install.packages('ggplot2')" && \
    Rscript -e "install.packages('argparse')" && \
    Rscript -e "install.packages('jsonlite')" && \
    Rscript -e "install.packages('shiny')" && \
    Rscript -e "install.packages('stringr')" && \
    Rscript -e "install.packages('BiocManager')" && \
    Rscript -e "BiocManager::install(version = '3.14')" && \
    Rscript -e "BiocManager::install('SingleCellExperiment')" && \
    Rscript -e "BiocManager::install('scuttle')" && \
    Rscript -e "BiocManager::install('scran')" && \
    Rscript -e "BiocManager::install('scater')" && \
    Rscript -e "BiocManager::install('rtracklayer')" && \
    Rscript -e "BiocManager::install('DropletUtils')" && \
    Rscript -e "BiocManager::install('org.Hs.eg.db')" && \
    Rscript -e "BiocManager::install('scDblFinder')" && \
    Rscript -e "install.packages('uwot')" && \
    Rscript -e "install.packages('tidyverse')" && \
    Rscript -e "install.packages('optparse')" && \
    Rscript -e "install.packages('remotes')" && \
    Rscript -e "remotes::install_github('mojaveazure/seurat-disk')"  

FROM satijalab/seurat:latest