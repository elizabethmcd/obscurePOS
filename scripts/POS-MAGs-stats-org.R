# Final POS genomes stats organization
setwd('/Users/emcdaniel/Desktop/McMahon-Lab/EBPR-Projects/obscurePOS')
library(tidyverse)

# genome list
list = read.csv("results/stats/final-dereplicated-genomes-list.csv")
stats = read_delim("results/stats/obscurePOS-dereplicated-bins-checkm-stats.tsv", delim='\t', col_names = c('bin', 'lineage', 'completeness', 'contamination', 'genome_size', 'contigs', 'percent_gc', 'unkown'))
info = stats %>% select(-lineage, -unkown)

# merge
merged = left_join(list, info)
write.csv(merged, 'results/stats/POS-MAGs-final-stats.csv', row.names=FALSE, quote=FALSE)
