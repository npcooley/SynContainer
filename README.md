# SynExtend Container

A container for using the R package SynExtend. The current version is `1.3.2`

## Usage

This container is built to be a toolbox for working with genomic data in R on the open science grid. It's current major package list includes:

* dendextend
* ape
* igraph
* DECIPHER
* SynExtend

It contains a few additional R packages as well dependencies for these major five. BLAST, HMMER, and MCL are included as well, and their executables have been added to the default PATH. This container also has the NCBI edirect tools, though users will need to supply their own API key. This container is currently built from `r-base:4.1.0`.

Versions:
1. BLAST `2.11.0`
2. HMMER `3.3.2`
3. MCL `14-137`
4. Bioconductor `3.13`

Details on SynExtend can be found [here](http://bioconductor.org/packages/release/bioc/html/SynExtend.html), and details on DECIPHER can be found [here](https://www.bioconductor.org/packages/release/bioc/html/DECIPHER.html).

It can be tested and used locally with `docker pull npcooley/synextend:1.3.1` and `docker run -i -t --rm synextend sh`.

It can be used as a singularity container on the OSG by specifying:

`+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/npcooley/synextend:1.3.0"`

in your submit file.

In this case the PATH for BLAST, HMMER, and edirect will need to be set with:

* `export PATH=$PATH:/blast/ncbi-blast-2.11.0+/bin`
* `export PATH=$PATH:/hmmer/hmmer-3.3.2/bin`
* `export PATH=$PATH:root/edirect`

in your executable/wrapper script.

## Contact

Nicholas Cooley
npc19@pitt.edu






