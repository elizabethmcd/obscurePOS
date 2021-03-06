# Manual Binning with Anvi'o 

Steps for this workflow followed the [tutorial](http://merenlab.org/2016/06/22/anvio-tutorial-v2/#anvi-merge) for the metagenomics workflow with some modifications, namely for importing taxonomy. Most of the steps were configured to run on the WEI GLBRC server using the job submit system to activate a conda environment, some of the small steps can be run manually. 

These steps were mostly done to manually bin eukaryotic bins from a photobioreactor ecosystem. Bacterial bins were automatically clustered using MetaBAT and assessed with CheckM and manually checked for uniform coverage. In addition to manual binning, I will also be performing binning with CONCOCT to attempt to extract eukaryotic bins, since binning algorithms like MaxBin and MetaBAT are biased towards binning prokaryotic sequences. 

## Binning from the full coassembly
Previously tried to bin with anvi'o from the full coassembly, and below are general steps/submits. Below are ways to subset the coassembly for eukaryotic contigs and bin from those. 

### Map metagenomic reads to the assembly

Map short metagenomic reads to the coassembly (this assumes you already have assembled contigs with metaSPAdes or some similar program) with bowtie2. The relevant submit job is `bowtie2-coassembly-queue.sub` where the reads will be mapped with bowtie2 (this assumes you have already made an index with `bowtie2-build`) and convert to BAM files, sort and index with Samtools. 

### Create a contigs database

Create a contigs database from your assembly collection of contigs FASTA file. Submit file is `anvi-gen-contigs.sub`. 

### Run HMMs on your contigs database

The default HMM collections are specifically for bacterial and archaeal markers, but downstream you can import your own HMM collections, such as eukaryotic markers from the BUSCO collection. I did not import my own HMM collections for now because I will probably assess individual bins with the BUSCO collection outside of Anvi'o once I have the clusters. 

### Import taxonomy 

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

### Profile BAM files and Merge

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

### View interactively on a server through SSH tunnel

Follow [this tutorial](http://merenlab.org/2015/11/28/visualizing-from-a-server/) for running an SSH tunnel through the server to get anvi-interactive to work on your local host from the results on the server. 



# Bin directly from classified Eukaryotic sequences

The coassembly is somewhat unnecessarily large for my purposes since I've already binned out bacterial genomes and dont' need that information. Since I was going to go directly to the contigs classified as Eukaryotic for manual clustering within the anvi'o interface, I will go ahead and make things easier and just feed those specific contigs to Anvi'o for manual binning. Additionally, I will do this for CONCOCT since I don't want to feed through the other bacterial contigs/genomes as well. The two main approaches for classifying contigs and subsetting the larger coassembly are: 

1. Subset with Eukrep
2. Classify contigs with Kaiju and pull those specific contigs out

THEN using these two subset assemblies of the coassembly: 

1. Manually bin with Anvi'o
2. Bin contigs with CONCOCT (can't use MaxBin or MetaBat because biased towards prokaryotic sequences)

## Binning from EukRep and Kaiju Contigs

### Make a contigs database

First subset the full coassembly for just contigs classified as eukaryotic based on Kaiju. This can be done with `seqtk`: `seqtk subseq ../coassembly_scaffolds.fasta eukaryotic-contigs.txt > coassembly_kaiju_euk.fasta`. Then use this new subset assembly to create a contigs database 

Create an anvi'o contigs database. To start will leave the default split size since it's a smaller assembly with about 85,000 contigs.  I will then also skip the HMM step because that won't be very helpful by default since I will have to run the BUSCO eukaryotic/chlorophyta collection either by specifically importing into Anvi'o, or just taking specific clusters and running outside of Anvi'o. Submit file is `eukrep-anvio-contigs-db.sub`

### Import taxonomy from Kaiju

Rerun taxonomy to help with phylum-level and down classifications with the Eukaryotes. First get the sequences from the anvi'o contigs database: `anvi-get-sequences-for-gene-calls -c CONTIGS.db -o gene_calls.fa`. Call classifications with Kaiju, which might be insightful since the eukrep sorting "identified" more eukaryotic contigs than what was originally classified with Kaiju from the coassembly. 

```
kaiju -t /path/to/nodes.dmp \
      -f /path/to/kaiju_db.fmi \
      -i gene_calls.fa \
      -o gene_calls_nr.out \
      -z 16 \
      -v
```

```
addTaxonNames -t /path/to/nodes.dmp \
              -n /path/to/names.dmp \
              -i gene_calls_nr.out \
              -o gene_calls_nr.names \
              -r superkingdom,phylum,order,class,family,genus,species
```

```
anvi-import-taxonomy-for-genes -i gene_calls_nr.names \
                               -c contigs.db \
                               -p kaiju --just-do-it
```

Noticed that the taxonomy breakdown from Kaiju for the sorted EukRep contigs has a lot of Bacteria and Viruses, and fewer of what is actually classified as Eukaryotic contigs from what the original Kaiju coassembly had. Especially in terms of the Chlorophyta, only included ~3000 contigs, whereas Kaiju classified 16,000 contigs from the full coassembly as Chlorophyta. Will still try both, but seems have a lot less to work with in terms of the actual eukaryotic content from the EukRep subset assembly. 

### Map to subset Eukrep assembly

`eukrep-mapping.sub` job to map each sample to the subset coassembly of eukaryotic contigs 


### Add custom HMM collections 

I pulled down the BUSCO HMM collections for eukaryota and chlorophyta, since of the Eukaryota there seems to be the most Chlorophyta by Kaiju estimates of the full coassembly (listed below). The eukaryota collection has 1,098 genes, and the Chlorophyta collection has 1,519 genes. I ran `anvi-run-hmms` for these databases, and for the kaiju assembly got 


### Profile BAM Files and Merge

Profile with with submit job `anvi-profile-queue.sub` to profile the reads mapping from each sample to the subset coassembly. The cutoff for contigs if length less than 1,000 bp, which went from ~75,000 contigs to 25,000 contigs, and the split size is much smaller. Gets rid of a lot of small stuff, hopefully doesn't impact things too much in terms of binning efficiency and tracking the single copy genes. 

Then merge with `anvi-merge */PROFILE.db -o SAMPLES-MERGED -c contigs.db --enforce-hierarchical-clustering`. Will have to enforce the hierarchical clustering because the split size of 25,000 is just above the default split size of 20,000. But should be fine without allocating to a really high memory node. 

### Import Kaiju classifications 

Need to re-do the Kaiju classifications based on the gene calls made from the Anvi'o contigs DB. `anvi-get-sequences-for-gene-calls -c CONTIGS.db -o gene_calls.fa`. Get Kaiju classifications and import as described above. 

Taxonomy breakdown from these contigs: 

```
   2931  Apicomplexa
   9090  Ascomycota
   8627  Bacillariophyta
   4877  Basidiomycota
    256  Blastocladiomycota
     13  Cercozoa
  16140  Chlorophyta
   1574  Chytridiomycota
   2838  Ciliophora
    845  Cryptomycota
   1109  Discosea
    663  Endomyxa
   7385  Euglenozoa
   2864  Evosea
    350  Foraminifera
     89  Fornicata
    601  Haptista
    692  Heterolobosea
      5  Imbricatea
    238  Microsporidia
   1953  Mucoromycota
   8254  NA
      1  Olpidiomycota
    288  Parabasalia
    247  Perkinsozoa
    110  Preaxostyla
    780  Rhodophyta
     15  Tubulinea
    941  Zoopagomycota
```

### View interactively on a server through SSH tunnel

Follow [this tutorial](http://merenlab.org/2015/11/28/visualizing-from-a-server/) for running an SSH tunnel through the server to get anvi-interactive to work on your local host from the results on the server. 

ssh -L 8080:localhost:8080 me@blah.edu

# Overall results

When mapping and binning from coassembly contigs classified as eukaryotic sequences, and then overlaying with HMM profiles from the BUSCO eukaryotic and chlorophyta collections, a somewhat expected result happens. For a lot of contigs that cluster together by coverage, the completion is low and redundancy is high. Especially for things that have a higher count of chlorophyta markers, the completion will be 40% and the redundancy is 80%. Additionally, the mapping is quite high in sample 3 and reported SNVs from anvi'o (still uncertain how they are reporting that) are also very high. I'm thinking whatever are the eukaryotic sequences are either really abundant and/or exhibit a lot of strain variation and are resulting in fragmented assemblies in the coassembly. Which I was taking the easy way of going through the anvi'o steps with the coassembly, because it's easier to start with. So I will repeat everything for the 3 individual assemblies with these steps: 

1. Run kaiju on each individual assembly
2. Subset each assembly based on the eukaryotic sequences
3. Map to each subsetted assembly from all the samples to get differential coverage information
4. Go through the Anvi'o steps. This time don't add the taxonomy information back in because turns out that wasn't really helpful. When have the coverage information with the HMM count distribution, that's better to show stats of the contigs. Whereas taxonomy colors just made things confusing and I couldn't tell how to change the taxonomy levels and it showed it at the lowest level of classification (species/strain) and was very unhelpful. 


