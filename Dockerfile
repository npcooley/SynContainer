FROM r-base:4.0.3

# 'docker build --no-cache -t npcooley/synextend .'
# version after the synextend version / bioconductor release
# 'docker push npcooley/synextend:latest npcooley/synextend:1.2.0'
# singularity containers will need to start with 'export PATH=/blast/ncbi-blast-x.y.z+/bin:$PATH'
# singularity containers will need to start with 'export PATH=/hmmer/hmmer-x.y.z/bin:$PATH'
# 'docker run -i -t --rm npcooley/synextend' will run image locally
# 'docker run -i -t --rm  -v ~/localdata/:/mnt/mydata/ npcooley/synextend' and remove once it's been closed -- use to check packages, functions, etc...

RUN apt-get update && \
   apt-get -y install libgmp-dev && \
   apt-get -y install libcurl4-openssl-dev && \
   apt-get -y install libssl-dev
   
RUN install.r remotes \
   BiocManager \
   igraph \
   dendextend \
   ape \
   httr \
   stringr

RUN Rscript -e "BiocManager::install(version = '3.12')" && \
   Rscript -e "BiocManager::install(c('DECIPHER', 'SynExtend'))"

# change working directory to install BLAST
WORKDIR /blast/

# grab blast tarball from local directory
# COPY ncbi-blast-2.9.0+-x64-linux.tar.gz .
# untar, and add to path
# RUN tar -zxvpf ncbi-blast-2.9.0+-x64-linux.tar.gz
# ENV PATH=/blast/ncbi-blast-2.9.0+/bin:$PATH


# grab BLAST tarball from NCBI
RUN wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.10.1+-x64-linux.tar.gz && \
   tar -zxvpf ncbi-blast-2.10.1+-x64-linux.tar.gz

ENV PATH=/blast/ncbi-blast-2.10.1+/bin:$PATH

# go back to home and build a hmmer working directory
RUN cd .. 
WORKDIR /hmmer/

# grab HMMER and install
# there is a make python command missing here
RUN wget http://eddylab.org/software/hmmer/hmmer.tar.gz
RUN tar -zxf hmmer.tar.gz
RUN cd hmmer-3.3.1 \
  && ./configure --prefix /hmmer/hmmer-3.3.1 \
  && make \
  && make install

WORKDIR /

ENV PATH=/hmmer/hmmer-3.3.1/bin:$PATH
