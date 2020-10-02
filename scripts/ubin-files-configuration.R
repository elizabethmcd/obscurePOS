library(tidyverse)

# check POS MAGs with uBin

# SCG config file
SCG_config <- read.csv("raw_data/ref_MAGs/combo-test.csv")
SCG_config[is.na(SCG_config)] <- 0

stats <- read.delim("raw_data/ref_MAGs/POS-stats-configured.txt", header=FALSE, sep="\t")
colnames(stats) <- c("Bin", "scaffold", "GC", "length", "coverage")
stats[is.na(stats)] <- ''

taxonomy <- read.csv("results/POS-MAGs-table.csv") %>% select(bin, classification)
colnames(taxonomy) <- c("Bin", "taxonomy")

ubin_table <- left_join(stats, taxonomy) %>% select(scaffold, GC, coverage, length, taxonomy, Bin)

write.csv(SCG_config, "results/stats/SCG_POS_uBin_config.csv", quote=FALSE, row.names = FALSE)
write_delim(ubin_table, "results/stats/POS_uBin_taxonomy_table.txt", delim = "\t")
