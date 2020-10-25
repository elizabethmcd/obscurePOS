library(tidyverse)

# covg, nuc diversity, SNVs for all genomes > 10X coverage in each sample
diversity_table <- read.delim("results/strains/lists/10X_coverage_genomes_samples_profiles.txt", sep="\t")
diversity_table$bin <- gsub(".fa", "", diversity_table$bin)

# metadata
metadata_table <- read.csv("results/stats/POS-MAGs-table-highest-classf.csv") %>% select(bin, code, highest_classf)

# merged metadata
sample_codes_table <- left_join(metadata_table, diversity_table) %>% drop_na()

diversity_samples <- sample_codes_table %>% select(code, highest_classf, sample1_diversity, sample2_diversity)
diversity_samples %>% ggplot(aes(x=))