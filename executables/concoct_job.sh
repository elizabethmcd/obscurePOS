#! /bin/bash

# load CONCOCT environment
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset $PYTHONPATH
source activate concoct
PYTHONPATH=''

# activate environment
source activate concoct

# directory
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly

concoct_coverage_table.py coassembly_contigs10K.fa 