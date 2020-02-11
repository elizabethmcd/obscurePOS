#! /bin/bash 

######################
# Queue single metagenomic assemblies with SPAdes from list
# Elizabeth McDaniel
######################

# Metagenomic reads path queued from provided file
# Make sure reads have been filtered previously before assembly - garbage in = garbage out
metaPath1=$2
metaPath2=$3
sample=$1
outdir=/home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/

# Python path
#PYTHONPATH=/opt/bifxapps/bin/python3.4
    # use specific 3.4 python path for running SPADES
SPADESPATH=/opt/bifxapps/SPAdes-3.9.0-Linux/bin/

# Run spades
/opt/bifxapps/bin/python3.4 $SPADESPATH/spades.py -t 20 -m 500 -k 21,33,55,77,99,127 -1 $metaPath1 -2 $metaPath2 -o $outdir/$sample
