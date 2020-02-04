#! /bin/bash

###################
# Filtering metagenomic samples with fastp
# For use on WEI GLBRC servers running HT Condor
# Elizabeth McDaniel 
##################

# set path where fastp is installed in local home directory bin
FASTPATH=/home/GLBRCORG/emcdaniel/bin/

# queueing r1 r2 metagenomic reads and output folder/file names
sample=$1
file1=$2
file2=$3
out1=$4
out2=$5

$FASTPATH/fastp -i $file1 -I $file2 -o $out1 -O $out2 --cut_tail -h $sample.html