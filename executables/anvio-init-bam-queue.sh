#! /bin/bash

source /opt/bifxapps/miniconda3/etc/profile.d/conda.sh
unset $PYTHONPATH

# activate environment
conda activate anvio-6.2

# directory where data is
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly

# arguments
bam=$1
out=$2

anvi-init-bam $bam -o anvio_binning/$out

# exit environment
conda deactivate