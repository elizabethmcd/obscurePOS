#! /bin/bash

###################################
# Install CheckM within Conda and download HMM dataset
# conda create -n checkM python=3.6
# conda install -n checkM -c bioconda checkm-genom
# put dataset in a central location, such as the /bin where you have programs installed
# cd bin && mkdir checkm_data
# curl -L -O https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.g z&& tar -xzvf checkm_data_2015_01_16.tar.gz
# checkm data setRoot bin/checkm_data
# source activate checkM
###################################

# within your project directory create a directory for checkm output, somewhere near where all your bins are

mkdir checkm_stats
checkm lineage_wf -x .fa all_bins/ checkm_stats
checkm qa checkm_stats/lineage.ms checkm_stats/ -o 2 -f checkm_stats/checkm.out --tab_table
awk -F "\t" '{print $1"\t"$2"\t"$6"\t"$7"\t"$9"\t"$12"\t"$19}' checkm.out  > checkm_stats.tsv

# change headers to
# bin_id    lineage	completeness	contamination	genome_size	contigs	gc	ORFs

# Can feed into dRep with just the first 3 columns

awk '{print $1".fa"","$3","$4}' mcfa_checkm_stats.tsv > drepInputStats
# change headers to
# genome,completness,contamination
source activate pipenv # with dRep installed
# dependencies for drep: mash, MUMmer, others are optiona since feeding checkM stats into it

dRep dereplicate outputDir -g binDir/*.fa --genomeInfo checkmStats

# To classify with GTDB further
# on GLBRC use Ben P's installation of GTDB-tk
export PATH=/home/GLBRCORG/bpeterson26/miniconda3/bin:$PATH
unset PYTHONPATH
source activate gtdbtk

gtdbtk classify_wf \
        --cpus 16 \
        --extension fa \
        --genome_dir good_bins/ \
        --out_dir checkm_stats/GTDB

# Combine checkm and gtdb results

join -j1 -a1 -o1.1,1.2,2.3,2.4,2.5,2.6,2.7 <(sort -k1 gtdb.tsv) <(sort -k1 checkM.tsv) | column -t | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7}' > stats.tsv
