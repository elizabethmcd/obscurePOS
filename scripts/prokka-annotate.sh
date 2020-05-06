#! /bin/bash

for fasta in *.fa; do
    N=$(basename $fasta .fa);
    prokka --outdir $N --prefix $N --cpus 2 $fasta --centre X --compliant;
done
