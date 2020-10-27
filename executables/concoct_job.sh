#! /bin/bash

# load CONCOCT environment
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset $PYTHONPATH
source activate concoct
PYTHONPATH=''

# activate environment
source activate concoct

# directory where formatted files and mapping files are
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly/concoct_binning/

# already ran cut_up_fasta.py to cut contigs into smaller parts 

# Get coverage depth information for all mapped samples
concoct_coverage_table.py coassembly_contigs10K.bed *.sorted.bam > coverage_table.tsv

# Run CONCOCT
concoct --composition_file coassembly_contigs10K.fa --coverage_file coverage_table.tsv -b concoct_output/

# Merge clustering
merge_cutup_clustering.py concoct_output/clustering_gt1000.csv > concoct_output/clustering_merged.csv

# Extract bins as individual FASTA files 
mkdir concoct_output/fasta_bins
extract_fasta_bins.py original_contigs.fa concoct_output/clustering_merged.csv --output_path concoct_output/fasta_bins