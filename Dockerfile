FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TrimGaloreVersion 0.6.5
ENV BedToolsVersion=2.27.1
ENV BamToolsVersion=2.4.0
ENV SamToolsVersion=1.9
ENV CutAdaptVersion=1.18
ENV NumPyVersion=1.19.0
ENV SciPyVersion=1.2.3

RUN apt-get update       && \
    apt-get install -y   && \
        curl                \
        grep                \
        build-essential     \
        zip                 \
        unzip               \
        python3-pip         \
        python3.8           \
        openjdk-8-jre-headless && \
        ln -s /usr/bin/python3.8 /usr/local/bin/python  && \
        apt-get clean && \
        apt-get purge && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN pip3 install \
    numpy=${NumPyVersion} \
    scipy=${SciPyVersion} \
    cutadapt=${CutAdaptVersion}}

RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip -o fastqc.zip && \
    unzip fastqc.zip -d /usr/local/fastqc/ && \
    rm fastqc.zip && \
    lb -s /usr/local/fastqc/fastqc /user/local/bin/

RUN wget https://github.com/FelixKrueger/TrimGalore/archive/refs/tags/${TrimGaloreVersion}.tar.gz -o TrimGalore.zip && \
    unzip TrimGalore.zip -d /usr/local/trim_galore/ && \
    rm TrimGalore.zip && \
    ln -s /usr/local/trim_galore/trim_galore /usr/local/bin/

RUN conda install bedtools=${BedToolsVersion}} && \
    conda install bamtools=${BamToolsVersion}} && \
    conda install samtools=${SamToolsVersion}}
