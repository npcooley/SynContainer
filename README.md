# SynExtend Container

A container for using the R package SynExtend. The current version is `1.2.1`

## Usage

This container is built to be a toolbox for working with genomic data in R on the open science grid. It's current major package list includes:

* dendextend
* ape
* igraph
* DECIPHER
* SynExtend

It contains a few additional R packages as well dependencies for these major five. BLAST `2.11.0` and HMMER `3.3.2` are included as well, and their executables have been added to the default PATH. This container is currently built from `r-base:4.0.3`.

It can be tested and used locally with `docker pull npcooley/synextend:1.2.1` and `docker run -i -t --rm synextend sh`.

It can be used as a singularity container on the OSG by specifying:

`+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/npcooley/synextend:1.2.1"`

in your submit file.

In this case the PATH for BLAST and HMMER will need to be set with

* `export PATH=/blast/ncbi-blast-2.11.0+/bin:$PATH`
* `export PATH=/hmmer/hmmer-3.3.2/bin:$PATH`

in your executable/wrapper script.

## Contact

Nicholas Cooley
npc19@pitt.edu






