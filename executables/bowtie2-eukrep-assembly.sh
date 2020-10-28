#! /bin/bash

# arguments
fastq=$1
name=$2

# directory
cd /home/GLBRCORG/emcdaniel/obscurePOS/metagenomes/assemblies/coassembly/eukrep_anvio_binning

# bowtie mapping
/opt/bifxapps/bowtie2/bowtie2 -p 6 -x bt2/eukrep -U $fastq > $name.sam

# BAM, sort, index
/opt/bifxapps/samtools-1.9/bin/samtools view -S -b $name.sam > $name.bam
/opt/bifxapps/samtools-1.9/bin/samtools sort $name.bam -o $name.sorted.bam
/opt/bifxapps/samtools-1.9/bin/samtools index $name.sorted.bam $name.sorted.bam.bai