#! /bin/bash

###################
# Filtering metagenomic samples with fastp
# For use on WEI GLBRC servers running HT Condor
# Elizabeth McDaniel 
##################

# set path where fastp is installed in local home directory bin
FASTPATH=/home/GLBRCORG/emcdaniel/bin

# queueing r1 r2 metagenomic reads and output folder/file names
sample=$1
file1=$2
file2=$3
out1=$4
out2=$5

OUTTOSS=/home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/toss
MERGED=/home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/cleaned_fastqs/

$FASTPATH/fastp --in1 $file1 --in2 $file2 --out1 $out1 --out2 $out2 --unpaired1 $OUTTOSS/$sample.toss.R1.fastq --unpaired2 $OUTTOSS/$sample.toss.R2.fastq --merge --merged_out $MERGED/$sample.merged.fastq --failed_out $OUTTOSS/$sample.failed.fastq --detect_adapter_for_pe  --cut_tail --cut_tail_window_size 10 --cut_tail_mean_quality 20 -h $sample.html
