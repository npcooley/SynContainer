FROM r-base:4.3.0

# 'docker build --no-cache -t npcooley/synextend:latest -t npcooley/synextend:1.12.0 .'
# version after the synextend version / bioconductor release
# 'docker push npcooley/synextend --all-tags'
# singularity containers will need to start with 'export PATH=/blast/ncbi-blast-x.y.z+/bin:$PATH'
# singularity containers will need to start with 'export PATH=/hmmer/hmmer-x.y.z/bin:$PATH'
# 'docker run -i -t --rm npcooley/synextend sh' will run image locally
# 'docker run -i -t --rm  -v ~/localdata/:/mnt/mydata/ npcooley/synextend' and remove once it's been closed -- use to check packages, functions, etc...

# version things:
# blast
# hmmer
# MCL
# BiocVersion
# SPADES
ENV BLAST_VERSION "2.14.0"
ENV HMMER_VERSION "3.3.2"
ENV MCL_VERSION "14-137"
ENV BIOC_VERSION "3.17"
ENV SRA_VERSION "3.0.5"
ENV SPADES_VERSION "3.15.5"
ENV MASURCA_VERSION "4.1.0"

# OS Dependencies
RUN apt-get update && \
   apt-get -y install build-essential \
    software-properties-common \
    libgmp-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    openmpi-common \
    libopenmpi-dev \
    libzmq3-dev \
    curl \
    libxml2-dev \
    git \
    abyss \
    libboost-all-dev \
    cmake \
    python3 \
    python3-pip \
    samtools \
    bcftools \
    flex \
    libfl-dev \
    x11-apps \
    xvfb xauth xfonts-base \
    libcairo2-dev \
    libxt-dev \
    libx11-dev \
    libgtk2.0-dev \
    bioperl \
    libconfig-yaml-perl \
    libwww-perl \
    psmisc \
    mash \
    cwltool && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*
   
# PIP dependencies
RUN pip3 install --break-system-packages biopython \
   plotly \
   pandas \
   numpy \
   reportlab \
   checkm-genome \
   pysam

# this is not necessarily the right choice for a container that gets passed around the OSG
# but this can be stashed and sent along as needed
# this command will tell checkM where it's DB / DBs are located:
# checkm data setRoot <checkm_data_dir>
# checkm isn't necessarily the simplest plug and play tool, see github:
# https://github.com/Ecogenomics/CheckM
# RUN wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz

# CONDA install
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
   /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# CONDA dependencies
RUN conda config --add channels defaults && \
   conda config --add channels bioconda && \
   conda config --add channels conda-forge && \
   conda update -n base -c defaults conda && \
   conda install -c bioconda megahit && \
   conda install -c conda-forge -c bioconda metaplatanus && \
   conda install -c bioconda bowtie2 && \
   conda install -c bioconda hisat2 && \
   conda install -c bioconda minimap2 && \
   conda install -c bioconda fastp && \
   conda install -c bioconda spades && \
   conda install -c bioconda clinker-py && \
   conda install -c bioconda fastqc && \
   conda install -c bioconda raven-assembler && \
   conda install flye && \
   conda install -c conda-forge -c bioconda -c defaults canu && \
   # conda install -c conda-forge -c bioconda medaka && \
   conda install -c bioconda -c conda-forge diamond && \
   conda install -c bioconda pplacer && \
   conda install -c bioconda prodigal

# R initial dependencies from CRAN
RUN install.r remotes \
   BiocManager \
   igraph \
   dendextend \
   ape \
   httr \
   stringr \
   phytools \
   phangorn \
   TreeDist \
   nlme \
   cluster \
   deSolve \
   rvest \
   Cairo


# Ensure correct bioc version for DECIPHER and SynExtend
RUN Rscript -e "BiocManager::install(version = '$BIOC_VERSION') ; BiocManager::install(c('DECIPHER', 'SynExtend', 'rtracklayer', 'Rsamtools'), type = 'source')"


# EDirect
RUN sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)" && \
   cp -r /root/edirect/ /edirect/
ENV PATH=$PATH:/edirect

# BLAST
WORKDIR /blast/
# grab BLAST tarball from NCBI
RUN wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/$BLAST_VERSION/ncbi-blast-$BLAST_VERSION+-x64-linux.tar.gz && \
   tar -zxvpf ncbi-blast-$BLAST_VERSION+-x64-linux.tar.gz && \
   cd /

# PATH will need to updated on the OSG, but is present here for regular docker use...
ENV PATH=/blast/ncbi-blast-$BLAST_VERSION+/bin:$PATH

# HMMER
WORKDIR /hmmer/
RUN wget http://eddylab.org/software/hmmer/hmmer-$HMMER_VERSION.tar.gz
RUN tar -zxvf hmmer-$HMMER_VERSION.tar.gz
RUN cd hmmer-$HMMER_VERSION && \
   ./configure --prefix /hmmer/hmmer-$HMMER_VERSION && \
   make && \
   make install && \
   cd /
   
WORKDIR /

# PATH will need to updated on the OSG, but is present here for regular docker use...
ENV PATH=/hmmer/hmmer-$HMMER_VERSION/bin:$PATH

# SRATools
# COPY sratoolkit.$SRA_VERSION-ubuntu64.tar.gz ./sratoolkit.$SRA_VERSION-ubuntu64.tar.gz
RUN wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/$SRA_VERSION/sratoolkit.$SRA_VERSION-ubuntu64.tar.gz && \
  tar -xzvf sratoolkit.$SRA_VERSION-ubuntu64.tar.gz && \
  rm sratoolkit.$SRA_VERSION-ubuntu64.tar.gz

ENV PATH=$PATH:/sratoolkit.$SRA_VERSION-ubuntu64/bin

# SRA tools are weird and have an interactive setup step that needs to be circumvented
# I don't remember where this fix came from ... github maybe?
# OSG containers open in a /srv and not root this matters, but i don't remember why
RUN mkdir /root/sra-repository && \
   mkdir /root/ncbi
COPY user-settings.mkfg ./root/.ncbi/user-settings.mkfg
COPY user-settings.mkfg /root/ncbi/user-settings.mkfg
COPY user-settings.mkfg /root/.ncbi/user-settings.mkfg
COPY user-settings.mkfg /sratoolkit.$SRA_VERSION-ubuntu64/bin/ncbi/user-settings.mkfg

# ANICalculator has some weird permissions that need to be edited for use on the OSG
# without the chown commands it should work fine in a local docker container, i think...
COPY ANIcalculator_v1.tgz .
RUN tar -zxvf ANIcalculator_v1.tgz
ENV PATH=$PATH:/ANIcalculator_v1
RUN chown root:root ANIcalculator_v1 && \
  chmod +x ANIcalculator_v1/* && \
  rm ANIcalculator_v1.tgz


# SPAdes 
# currenly installing from conda? this installation hits a segfault ...
# RUN wget http://cab.spbu.ru/files/release$SPADES_VERSION/SPAdes-$SPADES_VERSION-Linux.tar.gz && \
#    tar -xzvf SPAdes-$SPADES_VERSION-Linux.tar.gz && \
#    rm SPAdes-$SPADES_VERSION-Linux.tar.gz
# ENV PATH=$PATH:/SPAdes-$SPADES_VERSION-Linux/bin

# Unicycler assembler
RUN git clone https://github.com/rrwick/Unicycler.git && \
   cd Unicycler && \
   python3 setup.py install && \
   cd ..

# SKESA assembler
RUN git clone https://github.com/ncbi/SKESA && \
   cd SKESA && \
   make -f Makefile.nongs && \
   cd ..
ENV PATH=$PATH:/SKESA/

RUN mkdir installmcl && \
  cd installmcl && \
  wget https://raw.githubusercontent.com/micans/mcl/main/install-this-mcl.sh -o install-this-mcl && \
  chmod u+x install-this-mcl.sh && \
  ./install-this-mcl.sh && \
  cd ..

ENV PATH=$PATH:/root/local/bin

RUN wget https://www.niehs.nih.gov/research/resources/assets/docs/artbinmountrainier2016.06.05linux64.tgz && \
  tar -xzvf artbinmountrainier2016.06.05linux64.tgz && \
  rm artbinmountrainier2016.06.05linux64.tgz

ENV PATH=$PATH:/art_bin_MountRainier

# pbsim3 for long read simulations
RUN git clone https://github.com/yukiteruono/pbsim3.git && \
  cd pbsim3 && \
  autoreconf -f -i && \
  ./configure && \
  make
  
ENV PATH=$PATH:/pbsim3/src

RUN git clone https://github.com/rrwick/Filtlong.git && \
  cd Filtlong && \
  make -j && \
  cd ..

ENV PATH=$PATH:/Filtlong/bin

# masurca
# this still errors out ... I'm assuming there's missing undocumented dependency
# RUN wget https://github.com/alekseyzimin/masurca/releases/download/v$MASURCA_VERSION/MaSuRCA-$MASURCA_VERSION.tar.gz && \
#   tar -xzvf MaSuRCA-$MASURCA_VERSION.tar.gz && \
#   cd MaSuRCA-$MASURCA_VERSION && \
#   /MaSuRCA-$MASURCA_VERSION/install.sh && \
#   cd .. && \
#   rm MaSuRCA-$MASURCA_VERSION.tar.gz


# RUN wget https://raw.githubusercontent.com/micans/mcl/main/build-mcl-21-257.sh

# RUN apt-get -y --fix-missing install gcc-9

# ENV CC=gcc-9
# ENV CXX=g++-9

# WORKDIR /mcl/
# RUN wget https://micans.org/mcl/src/mcl-$MCL_VERSION.tar.gz
# RUN tar -zxvf mcl-$MCL_VERSION.tar.gz --strip-components=1 && \
#    ./configure && \
# 	make install && \
# 	cd /

#RUN wget https://micans.org/mcl/src/mcl-$MCL_VERSION.tar.gz
#RUN tar xzf mcl-$MCL_VERSION.tar.gz && \
#   cd mcl-$MCL_VERSION && \
#   ./configure --prefix=$HOME/local && \
#   make install
	
# RUN unset CC
# RUN unset CXX

WORKDIR /
