#! /bin/bash

source /opt/bifxapps/miniconda3/etc/profile.d/conda.sh
unset $PYTHONPATH

# activate environment
conda activate anvio-6.2

# directory where data is
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly/anvio_binning

# arguments
bam=$1
name=$2

anvi-profile -i $bam -c contigs.db --output-dir $name --sample-name $name

# exit environment
conda deactivate