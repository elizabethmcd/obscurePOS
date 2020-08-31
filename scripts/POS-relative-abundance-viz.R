library(tidyverse)
library(reshape2)
library(viridis)

# POS Genomes stats 
pos_stats <- read.csv("results/stats/POS-MAGs-final-stats.csv")

# Mapping stats
pos_mapping <- read.delim("results/mapping/POS-rel-abund-calculations.txt", sep = "\t", header = FALSE)
colnames(pos_mapping) <- c("bin", "2015-07-16", "2015-07-24", "2015-08-06")

# Merged table
pos_table <- left_join(pos_stats, pos_mapping)
colnames(pos_table) <- c("bin", "code", "classification", "completeness", "contamination", "genome_size", "contigs", "percent_gc", "rRNA_count", "tRNA_count", "rRNA_5S", "rRNA_16S", "rRNA_23S", "abund_2015-07-16", "abund_2015-07-24", "abund_2015-08-06")

# Cleaned taxa names
pos_names <- pos_table %>%
  separate(classification, into=c("kingdom", "phylum", "class", "order", "family", "genus", "species"), sep=";")

# table for melting to make plot
pos_abundance <- pos_names %>% 
  select(code, phylum, `abund_2015-07-16`, `abund_2015-07-24`, `abund_2015-08-06`)
pos_abundance$average <- (pos_abundance$`abund_2015-07-16` + pos_abundance$`abund_2015-07-24` + pos_abundance$`abund_2015-08-06`) / 3

# plot
pos_abundance %>% ggplot(aes(x=reorder(code, -average), y=average, fill=phylum)) + geom_col() + theme_classic() + scale_fill_brewer(palette="Paired")

# write table
pos_table$avg_abundance <- (pos_table$`abund_2015-07-16` + pos_table$`abund_2015-07-24` + pos_table$`abund_2015-08-06`) / 3
write.csv(pos_table, "results/stats/POS-MAGs-table.csv", quote=FALSE, row.names = FALSE)

# highest classifcation codes
pos_names <- read.csv("results/stats/POS-MAGs-table-highest-classf.csv")
pos_names$avg <- (pos_names$abund_2015.07.16 + pos_names$abund_2015.07.24 + pos_names$abund_2015.08.06) / 3
avg_abundance <- pos_names %>% ggplot(aes(x=reorder(code, -avg), y=avg, fill=highest_classf)) + geom_col() + theme_classic() + scale_fill_brewer(palette="Paired") + theme(axis.text.x= element_text(angle=85, hjust=1))

# melted dataset for heatmap of specific taxa
pos_counts <- pos_table %>% select(code, `abund_2015-07-16`, `abund_2015-07-24`, `abund_2015-08-06`)
pos_melt <- melt(pos_counts, id.vars="code", variable="date")

top_10 <- pos_table %>% 
  select(code, avg_abundance) %>% 
  arrange(desc(avg_abundance)) %>% 
  head(n=10) %>% 
  pull(code)

top_ts <- pos_melt %>% filter(code %in% top_10)

top_heatmap <- ggplot(top_ts, aes(x=code, y=fct_rev(date), fill=value)) + geom_tile(color="white") + scale_fill_viridis(option="viridis", alpha=1, begin=0, end=1, direction=-1) + theme(axis.text.x= element_text(angle=85, hjust=1))
top_heatmap

# save raw figures

ggsave(plot=avg_abundance, filename="figs/POS-average-abundance-bars.png", units=c("cm"), width=20, height=9)
ggsave(plot=top_heatmap, filename="figs/POS-top10-heatmap.png", units=c("cm"), width=14, height=4)


