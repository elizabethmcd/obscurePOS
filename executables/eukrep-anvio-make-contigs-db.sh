#! /bin/bash

source /opt/bifxapps/miniconda3/etc/profile.d/conda.sh
unset $PYTHONPATH

# activate environment
conda activate anvio-6.2

# directory where data is
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly/eukrep_anvio_binning

# run anvi-make-contigs-db

anvi-gen-contigs-database -f coassembly-euk.fasta -o contigs.db -n "eukrep_coassembly_contigs"

# exit environment
conda deactivate