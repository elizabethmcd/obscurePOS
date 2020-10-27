# Manual Binning with Anvi'o 

Steps for this workflow followed the [tutorial](http://merenlab.org/2016/06/22/anvio-tutorial-v2/#anvi-merge) for the metagenomics workflow with some modifications, namely for importing taxonomy. Most of the steps were configured to run on the WEI GLBRC server using the job submit system to activate a conda environment, some of the small steps can be run manually. 

These steps were mostly done to manually bin eukaryotic bins from a photobioreactor ecosystem. Bacterial bins were automatically clustered using MetaBAT and assessed with CheckM and manually checked for uniform coverage. In addition to manual binning, I will also be performing binning with CONCOCT to attempt to extract eukaryotic bins, since binning algorithms like MaxBin and MetaBAT are biased towards binning prokaryotic sequences. 

## Map metagenomic reads to the assembly

Map short metagenomic reads to the coassembly (this assumes you already have assembled contigs with metaSPAdes or some similar program) with bowtie2. The relevant submit job is `bowtie2-coassembly-queue.sub` where the reads will be mapped with bowtie2 (this assumes you have already made an index with `bowtie2-build`) and convert to BAM files, sort and index with Samtools. 

## Create a contigs database

Create a contigs database from your assembly collection of contigs FASTA file. Submit file is `anvi-gen-contigs.sub`. 

## Run HMMs on your contigs database

The default HMM collections are specifically for bacterial and archaeal markers, but downstream you can import your own HMM collections, such as eukaryotic markers from the BUSCO collection. I did not import my own HMM collections for now because I will probably assess individual bins with the BUSCO collection outside of Anvi'o once I have the clusters. 

## Import taxonomy 

Since I am specifically looking to bin eukaryotic genomes with this workflow, I want to know ***a priori** what contigs are likely eukaryotic to then cluster into bins. I followed [this tutorial](http://merenlab.org/2016/06/18/importing-taxonomy/) to format Kaiju classifications correctly and import into my contigs DB. I already have Kaiju installed on GLBRC as well as the NCBI NR databases for bacterial, archaeal, fungal, and eukaryotic references downloaded and formatted. Briefly, you can pull down specific databases and format them with the kaiju `makeDB.sh` script (which now I know you can multi-thread, otherwise it will take forever). 

Before doing any profiling of the mapping files, import your gene sequences from the contigs DB: 

```
anvi-get-sequences-for-gene-calls -c CONTIGS.db -o gene_calls.fa
```

Then run Kaiju:

```
kaiju -t /path/to/nodes.dmp \
      -f /path/to/kaiju_db.fmi \
      -i gene_calls.fa \
      -o gene_calls_nr.out \
      -z 16 \
      -v
```

Then format the Kaiju names and follow the classification output SPECIFICALLY because Anvi'o expects it in this certain order of kingdom > phylum etc...

```
addTaxonNames -t /path/to/nodes.dmp \
              -n /path/to/names.dmp \
              -i gene_calls_nr.out \
              -o gene_calls_nr.names \
              -r superkingdom,phylum,order,class,family,genus,species
```

Import into Anvi'o contigs db: 

```
anvi-import-taxonomy-for-genes -i gene_calls_nr.names \
                               -c contigs.db \
                               -p kaiju --just-do-it
```

Add the "just do it" flag to force it, and it will give you a check of what Anvi'o thinks the phylum names are from Kaiju. Make sure they are right before completing this step. 

## Profile BAM files and Merge

This assumes you already have sorted and indexed BAM files for each of your mapped samples to the coassembly. If not you can do it with samtools or with the anvi'o program `anvi-init-bam`, which corresponds to the `anvi-bam-init-queue.sub` submit file. Then profile each of your BAM files with `anvi-profile-queue.sub`. Then merge the profiles with `anvi-merge */PROFILE.db -o SAMPLES-MERGED -c contigs.db --enforce-hierarchical-clustering`. Hierarchical clustering has to be forced because the default clustering for number of splits is around 25,000, whereas there are about 270,000 splits for this contigs database, probably because it's a complex coassembly. This will need to be submitted to one of the larger nodes with more memory because the error thrown when just ran on scarcity-7 alone is: 

```
WARNING
===============================================
Clustering has failed for "cov": "Unable to allocate 288. GiB for an array with
shape (38709444403,) and data type float64"
```

So needs around ~300GB of memory, can probably give 500GB and see how long that takes to submit/run. Others have said on the anvi'o github issues that increasing memory helps, but visualizing that many splits might be difficult. Uncertain at this point of how to decrease the numbers of splits in the contigs.db. This submit file is `anvi-merge-job.sub` and allocated about 500GB of memory and 10 CPUs to start with. If this works and visualizing that many splits becomes difficult, might have to play around with changing the split size of the contigs (default = contigs longer than 20,000 bp get split into shorter contigs, could double or triple that size because then contigs longer than 60,000 bp for example would only get split into smaller pieces, whereas things less than that size just stay the size of the original contig if I am interpreting things correctly). If have to change the contigs.db then probably have to start everything over from calling genes, importing the taxonomy, and definitely re-profiling the mapping BAM files. Will see how things look visually since I really just want the eukaryotic things. 

```
Anvi'o just set the normalization values for each sample based on how many
mapped reads they contained. This information will only be used to calculate the
normalized coverage table. Here are those values: POS_Sample1: 0.88,
POS_Sample2: 1.00, POS_Sample3: 0.73
```

So the second samples for 2015-07-24 mapped the best to the coassembly, the third in August the worst, and the first before the light switch so-so.  

## View interactively on a server through SSH tunnel

Follow [this tutorial](http://merenlab.org/2015/11/28/visualizing-from-a-server/) for running an SSH tunnel through the server to get anvi-interactive to work on your local host from the results on the server. 

