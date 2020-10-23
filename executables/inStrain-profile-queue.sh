#! /bin/bash 

# load inStrain environment
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate pipenv
PYTHONPATH=''

# arguments
genome=$1
code=$2
genomePath=/home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/finalBins/bins
input=$genomePath/$genome.fa
annotationPath=/home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/finalBins/annotations

# setup
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/finalBins/strains

# profile each genome for 2015-07-16 sample

inStrain profile /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/finalBins/strains/POS-2015-07-16-mapping.sorted.bam $input -o results/$code.IS -p 8 -g $annotationPath/$genome/$genome.ffn 



