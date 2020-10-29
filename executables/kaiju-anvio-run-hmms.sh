#! /bin/bash

source /opt/bifxapps/miniconda3/etc/profile.d/conda.sh
unset $PYTHONPATH

# activate environment
conda activate anvio-6.2

# directory where data is
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly/kaiju_anvio_binning

# directory where BUSCO DBs are
BUSCO=/home/GLBRCORG/emcdaniel/bin/BUSCO_DBs


# run anvi-make-contigs-db for each DB of specific HMMs for eukaryotes and chlorophyta

anvi-run-hmms -c contigs.db -H $BUSCO/eukaryota_anvio -T 8
anvi-run-hmms -c contigs.db -H $BUSCO/chlorophyta_anvio/ -T 8

# exit environment
conda deactivate