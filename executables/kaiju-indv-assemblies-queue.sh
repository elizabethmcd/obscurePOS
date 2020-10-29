#! /bin/bash 

# arguments

assembly=$1
name=$2

# directory
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/final_assemblies

mkdir $name 

# kaiju run
~/../bpeterson26/programs/kaiju-v1.6.3-linux-x86_64-static/bin/kaiju -t /home/GLBRCORG/emcdaniel/bin/kaiju/DB/nodes.dmp -f /home/GLBRCORG/emcdaniel/bin/kaiju/DB/kaiju_db_nr_euk.fmi -i $assembly -o $name/$name-kaiju-nr.out -z 6 -v

# add taxon names 
~/../bpeterson26/programs/kaiju-v1.6.3-linux-x86_64-static/bin/addTaxonNames -t /home/GLBRCORG/emcdaniel/bin/kaiju/DB/nodes.dmp -n /home/GLBRCORG/emcdaniel/bin/kaiju/DB/names.dmp -i $name/$name-kaiju-nr.out -o $name/$name-kaiju-names.out -r superkingdom,phylum,order,class,family,species

# reorganize the results
awk -F "\t" '{print $2"\t"$8}' $name/$name-kaiju-names.out | grep Eukaryota > $name/$name-eukaryotic-contig-classification-table.txt

awk -F "\t" '{print $2}' $name/$name-eukaryotic-contig-classification-table.txt | awk -F ';' '{print $2}' | sort | uniq -c > $name/$name-eukaryotic-contigs-counts.txt

awk '{print $1}' $name/$name-eukaryotic-contig-classification-table.txt > $name/$name-eukaryotic-contigs-list.txt

~/bin/seqtk subseq $name-assembly-contigs.fasta $name/$name-eukaryotic-contigs-list.txt > $name/$name-kaiju-eukaryotic-contigs.fasta

