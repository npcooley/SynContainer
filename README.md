# SynExtend Container

A container for using the R package SynExtend.

## Usage

This container is built to be a toolbox for working with genomic data in R on the open science grid. It's current major package list includes:

* dendextend
* ape
* igraph
* DECIPHER
* SynExtend

It contains a few additional R packages as well dependencies for these major five. BLAST `2.10.1` and HMMER `3.3.1` are included as well, and their executables have been added to the default PATH. This container is currently built from `r-base:4.0.3`.

It can be tested and used locally with `docker pull npcooley/synextend:latest` and `docker run -i -t --rm synextend sh`.

It can be used as a singularity container on the OSG by specifiying `+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/npcooley/synextend:latest"` in your submit file. In this case the PATH for BLAST and HMMER will need to be set with `export PATH=/blast/ncbi-blast-2.10.1+/bin:$PATH` and `export PATH=/hmmer/hmmer-3.3.1/bin:$PATH` in the wrapper script respectively.

## Contact

Nicholas Cooley
npc19@pitt.edu






