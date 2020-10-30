# SynExtend Container

A container for using the R package SynExtend.

## Usage

This container is built to be a toolbox for working with genomic data in R on the open science grid. It's current major package list includes:

* dendextend
* ape
* DECIPHER
* SynExtend

It contains a few additional R packages as well dependencies for these major 4. BLAST v`2.10.1` and HMMER v`3.3.1` are included as well, and their executables have been added to the default PATH. This container is currently built from `r-base:4.0.3`.

It can be tested and used locally as well with `docker pull npcooley/synextend:latest` and `docker run -i -t --rm synextend`.

## Contact

Nicholas Cooley
npc19@pitt.edu






