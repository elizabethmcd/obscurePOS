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

strainsPath=/home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/finalBins/strains

# setup
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/finalBins/strains

# profile each genome for 2015-07-16 sample
# Mapped competitively to all genomes using bowtie2
# Called genes from the combined genome file with Prodigal - this is the genes file
# Individually queue by each genome to calculate individual microdiversity metrics by genome, provide scaffold to bin (STB) file for this 

inStrain profile $strainsPath/POS-2015-07-16-mapping.sorted.bam $genomePath/$genome.fa -o results/$code.IS -p 8 -g $strains/all-all-POS-genomes-genes.fna -s POS-scaffolds-to-bins.stb



