library(tidyverse)
library(reshape2)
library(viridis)
library(viridisLite)

# covg, nuc diversity, SNVs for all genomes > 10X coverage in each sample
diversity_table <- read.delim("results/strains/lists/10X_coverage_genomes_all_samples_profiles.txt", sep="\t")
diversity_table$bin <- gsub(".fa", "", diversity_table$bin)

# metadata
metadata_table <- read.csv("results/stats/POS-MAGs-table-highest-classf.csv") %>% select(bin, code, highest_classf)

# merged metadata
sample_codes_table <- left_join(metadata_table, diversity_table) %>% drop_na()

diversity_samples <- sample_codes_table %>% select(code, sample1_diversity, sample2_diversity, sample3_diversity)
colnames(diversity_samples) <- c("code", "2015-07-16", "2015-07-24", "2015-08-06")

diversity.melted <- melt(diversity_samples, id.vars="code")
colnames(diversity.melted) <- c("code", "date", "diversity")
names <- metadata_table %>% select(code, highest_classf)
melted.names <- left_join(diversity.melted, names)
melted.names$date <- ordered(melted.names$date, levels=c("2015-07-16", "2015-07-24", "2015-08-06"))
melted.names$highest_classf <- gsub("Beta/Gammaproteobacteria", "Proteobacteria", melted.names$highest_classf)
melted.names$highest_classf <- gsub("Alphaproteobacteria", "Proteobacteria", melted.names$highest_classf)
melted.names$highest_classf <- gsub("Deltaproteobacteria", "Proteobacteria", melted.names$highest_classf)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
diversity <- melted.names %>% ggplot(aes(x=factor(date), y=diversity, group=code, color=code)) + geom_point() + geom_line() + scale_fill_manual(values=cbPalette) + scale_y_continuous(limits=c(0, .01), expand=c(0,0)) + theme_bw()
ggsave("figs/nucleotide-diversity.png", diversity, width=15, height=10, units=c("cm"))
# covg for all genomes
covg <- read.delim("results/strains/covg_results/POS-all-samples-covg-diversity.txt", sep="\t")
covg$bin <- gsub(".fa", "", covg$bin)
covg_table <- left_join(metadata_table, covg) %>% select(code, sample1_coverage, sample2_coverage, sample3_coverage)
colnames(covg_table) <- c("code", "2015-07-16", "2015-07-24", "2015-08-06")
covg.melted <-  melt(covg_table, id.vars="code")
colnames(covg.melted) <- c("code", "date", "coverage")
covg.names <- left_join(covg.melted, names)
covg.names$date <- ordered(covg.names$date, levels=c("2015-07-16", "2015-07-24", "2015-08-06"))
covg.names %>% ggplot(aes(x=factor(date), y=coverage, group=code, color=highest_classf)) + geom_point() + geom_line() + theme_bw()

# coverage with relative abundance 
coverage <- diversity_table %>% select(bin, sample1_coverage, sample2_coverage, sample3_coverage)
metadata_abund <- read.csv("results/POS-MAGs-table.csv") %>% select(bin, code, classification, abund_2015.07.16, abund_2015.07.24, abund_2015.08.06)
abund_covg_table <- left_join(coverage, metadata_abund) %>% select(code, classification, abund_2015.07.16, sample1_coverage, abund_2015.07.24, sample2_coverage, abund_2015.08.06, sample3_coverage)
write.csv(abund_covg_table, "results/strains/covg_results/abundance_coverage_top24_table.csv", quote=FALSE, row.names = FALSE)
