FROM r-base:4.1.2

# 'docker build --no-cache -t npcooley/synextend:latest -t npcooley/synextend:dev .'
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
ENV BLAST_VERSION "2.11.0"
ENV HMMER_VERSION "3.3.2"
ENV MCL_VERSION "14-137"
ENV BIOC_VERSION "3.14"

# Dependencies
RUN apt-get update && \
   apt-get -y install build-essential && \
   apt-get -y install libgmp-dev && \
   apt-get -y install libcurl4-openssl-dev && \
   apt-get -y install libssl-dev && \
   apt-get -y install openmpi-common && \
   apt-get -y install curl
   
RUN install.r remotes \
   BiocManager \
   igraph \
   dendextend \
   ape \
   httr \
   stringr \
   deSolve

RUN Rscript -e "BiocManager::install(version = '$BIOC_VERSION') ; BiocManager::install(c('DECIPHER', 'SynExtend'))"

COPY DECIPHER_2.21.1.tar.gz ./DECIPHER_2.21.1.tar.gz
RUN tar -zxvf ./DECIPHER_2.21.1.tar.gz
   
RUN R CMD build --no-build-vignettes --no-manual ./DECIPHER && \
   R CMD INSTALL DECIPHER_2.21.1.tar.gz

# EDirect
RUN sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"

ENV PATH=$PATH:/root/edirect


# change working directory to install BLAST
WORKDIR /blast/

# grab blast tarball from local directory
# COPY ncbi-blast-2.9.0+-x64-linux.tar.gz .
# untar, and add to path
# RUN tar -zxvpf ncbi-blast-2.9.0+-x64-linux.tar.gz
# ENV PATH=/blast/ncbi-blast-2.9.0+/bin:$PATH


# grab BLAST tarball from NCBI
RUN wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/$BLAST_VERSION/ncbi-blast-$BLAST_VERSION+-x64-linux.tar.gz && \
   tar -zxvpf ncbi-blast-$BLAST_VERSION+-x64-linux.tar.gz && \
   cd /

# PATH will need to updated on the OSG, but is present here for regular docker use...
ENV PATH=/blast/ncbi-blast-$BLAST_VERSION+/bin:$PATH

# grab HMMER and install
# there is a make python command missing here
WORKDIR /hmmer/
RUN wget http://eddylab.org/software/hmmer/hmmer-$HMMER_VERSION.tar.gz
RUN tar -zxvf hmmer-$HMMER_VERSION.tar.gz
RUN cd hmmer-$HMMER_VERSION && \
   ./configure --prefix /hmmer/hmmer-$HMMER_VERSION && \
   make && \
   make install && \
   cd /

# PATH will need to updated on the OSG, but is present here for regular docker use...
ENV PATH=/hmmer/hmmer-$HMMER_VERSION/bin:$PATH

RUN apt-get -y install gcc-9

ENV CC=gcc-9
ENV CXX=g++-9

WORKDIR /mcl/
RUN wget https://micans.org/mcl/src/mcl-$MCL_VERSION.tar.gz
RUN tar -zxvf mcl-$MCL_VERSION.tar.gz --strip-components=1 && \
   ./configure && \
	make install && \
	cd /

#RUN wget https://micans.org/mcl/src/mcl-$MCL_VERSION.tar.gz
#RUN tar xzf mcl-$MCL_VERSION.tar.gz && \
#   cd mcl-$MCL_VERSION && \
#   ./configure --prefix=$HOME/local && \
#   make install
	
RUN unset CC
RUN unset CXX

WORKDIR /



