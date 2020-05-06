library(ampvis2)
library(tidyverse)

pos <- read.csv("raw_data/POS_16Sotu_table.csv")

# taxonomy split into separate columns
pos_cleaned <- pos %>%
  mutate(Taxonomy = str_replace_all(string=Taxonomy, pattern="\\(\\d*\\)", replacement="")) %>% 
  mutate(Taxonomy = str_replace_all(string=Taxonomy, pattern=";$", replacement="")) %>% 
  separate(Taxonomy, into=c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus"), sep=";") %>% 
  select(-Size) %>% 
  select(OTU, S1, S2, S3, S4, S5, S6, S7, Kingdom, Phylum, Class, Order, Family, Genus)

# genera most abundant in sample7 at end of enrichment period
pos_cleaned %>% 
  select(OTU, S7, Genus) %>% 
  group_by(Genus)

# add blank species column to import into ampvis2, wasn't classified at this level previously
pos_cleaned$Species <- NA
         
# metadata
pos_metadata <- read.csv("metadata/POS_16Sotu_metadata.csv")

# ampvis2 object
pos_amp <- amp_load(otutable = pos_cleaned, metadata=pos_metadata)

# heatmap

otu_pos <- amp_heatmap(pos_amp, tax_aggregate = "OTU", tax_show=5, plot_values = FALSE, min_abundance=0, plot_legendbreaks=c(0,0.05,.10,.15,.2), plot_colorscale="sqrt", normalise = FALSE) + theme(axis.text.y = element_text(size=8), legend.position="right") + theme(legend.position="none", axis.ticks.y=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank())

ggsave(plot=otu_pos, file="~/Desktop/pos_otu_heatmap.png", width=15, height=5, units=c('cm'))

