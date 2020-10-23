# Final POS genomes stats organization
library(tidyverse)

# genome list
list = read.csv("results/stats/final-dereplicated-genomes-list.csv")
stats = read_delim("results/stats/obscurePOS-dereplicated-bins-checkm-stats.tsv", delim='\t', col_names = c('bin', 'lineage', 'completeness', 'contamination', 'genome_size', 'contigs', 'percent_gc', 'unkown'))
info = stats %>% select(-lineage, -unkown)

# merge
merged = left_join(list, info)
write.csv(merged, 'results/stats/POS-MAGs-final-stats.csv', row.names=FALSE, quote=FALSE)

# after more manual curation
final_stats <- read.csv("results/stats/POS-MAGs-final-stats.csv")

final_stats %>% filter(completeness > 95 & contamination < 5) %>% count()
final_stats %>% filter(completeness > 90 & contamination < 10) %>%  count()
final_stats %>% filter(tRNA > 18) %>% count()
final_stats %>% filter(rRNA >= 3) %>% count()
final_stats %>% filter(X5S >= 1) %>% count()
final_stats %>% filter(X16S >= 1) %>% count()
final_stats %>% filter(X23S >= 1) %>% count()
