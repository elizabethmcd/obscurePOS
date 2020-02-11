#! /bin/bash

###################
# Filtering metagenomic samples with BBduk part of the BBtools package
# For use on WEI GLBRC servers running HT Condor
# Elizabeth McDaniel 
##################

# set path where fastp is installed in local home directory bin
BBPATH=/opt/bifxapps/bbmap-38.32/

# queueing r1 r2 metagenomic reads and output folder/file names
sample=$1
file1=$2
file2=$3
out1=$4
out2=$5

$BBPATH/bbduk.sh in=$file1 in2=$file2 out=$out1 out2=$out2 qtrim=r trimq=10 maq=10
