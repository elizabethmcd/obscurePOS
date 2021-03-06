library(tidyverse)

setwd('/Users/emcdaniel/Desktop/McMahon-Lab/EBPR-Projects/obscurePOS')

# ANI results
ani <- read_delim('results/stats/obscurePOS.all.ani.out.cleaned.txt', delim="\t", col_names=FALSE)
colnames(ani) <- c("bin1","bin2", "ANI1", "ANI2", "AF1", "AF2")
ani_groups <- ani %>% filter(ANI1 > 95)
ani_groups$bin1 <- gsub(".fna","", ani_groups$bin1)
ani_groups$bin2 <- gsub(".fna","", ani_groups$bin2)

# checkm stats
stats <- read_delim('results/stats/obscurePOS-dereplicated-bins-checkm-stats.tsv', delim="\t", col_names=FALSE)
colnames(stats) <- c("bin", "classf", "comp", "contam", "size", "contigs", "gc", "X")
info <- stats %>% select(bin, comp, contam, size, contigs)

# classifications
classf <- read_delim('results/stats/obscurePOS-dereplicated-bins-gtdb-classifications.tsv', delim='\t', col_names=FALSE)
colnames(classf) <- c("bin", "classf")

# merging tables
ani_stats1 <- left_join(ani_groups, info, by=c("bin1" = "bin"))
colnames(ani_stats1) <- c("bin1", "bin2", "ANI1", "ANI2", "AF1", "AF2", "comp1", "contam1", "size1", "contigs1")
ani_stats2 <- left_join(ani_stats1, info, by=c("bin2" = "bin"))
colnames(ani_stats2) <- c("bin1", "bin2", "ANI1", "ANI2", "AF1", "AF2", "comp1", "contam1", "size1", "contigs1", "comp2", "contam2", "size2", "contigs2")
ani_clusters <- left_join(ani_stats2, classf, by=c("bin1" = "bin"))
cluster_table <- ani_clusters %>% select(bin1, bin2, classf, ANI1, ANI2, AF1, AF2, comp1, comp2, contam1, contam2, size1, size2, contigs1, contigs2)
ani_table <- cluster_table[-1,]

# write table
write.csv(ani_table, "results/stats/cluster-table-raw.csv", row.names=FALSE, quote=FALSE)
