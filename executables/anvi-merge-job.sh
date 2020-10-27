#! /bin/bash

source /opt/bifxapps/miniconda3/etc/profile.d/conda.sh
unset $PYTHONPATH

# activate environment
conda activate anvio-6.2

# directory where data is
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly/anvio_binning

# Merge profiles and enforce hierarchical clustering
anvi-merge */PROFILE.db -o SAMPLES-MERGED -c contigs.db --enforce-hierarchical-clustering