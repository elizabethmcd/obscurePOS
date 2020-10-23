library(tidyverse)
library(reshape2)
library(viridis)

# matrix input from fastani
ani <- read.table("results/ppk1/POS-ac-comparisons.txt") %>% select(V1, V2, V3)
colnames(ani) <- c("bin1", "bin2", "ANI")

# accumulibacter metadata information
ac_metadata <- read.csv("metadata/accumulibacter-genomes-refs-information.csv", stringsAsFactors = FALSE)
keep <- ani %>% filter(bin1 != "GCA_009467885.1" & bin2 != "GCA_009467885.1")
clade_order <- c('2687453699.fna',
                 'GCA_000585075.1.fna',
                 'GCA_002455435.1.fna',
                 'GCA_009467855.1.fna',
                 'spades-bin.32.fna',
                 'POS2015-07-24-bin.54.fna',
                 'GCA_000585055.1.fna',
                 'GCA_000987445.1.fna',
                 'GCA_002352265.1.fna',
                 'GCA_003332265.1.fna',
                 '2767802316.fna',
                 'GCA_000024165.1.fna',
                 'POS2015-07-16-bin.58.fna',
                 'POS2015-08-06-bin.38.fna',
                 '2767802455.fna',
                 'GCA_000584955.2.fna',
                 'GCA_000584975.2.fna',
                 'GCA_000585035.2.fna',
                 'GCA_000987395.1.fna',
                 'GCA_002425405.1.fna',
                 'GCA_005889575.1.fna',
                 'coassembly-bin.185.fna',
                 'coassembly-bin.12.fna',
                 'GCA_000584995.1.fna',
                 'GCA_000585015.1.fna',
                 'GCA_000585095.1.fna',
                 'GCA_002345025.1.fna',
                 'GCA_002345285.1.fna',
                 'GCA_002433845.1.fna',
                 'GCA_003487685.1.fna',
                 'GCA_003535635.1.fna',
                 'GCA_003542235.1.fna',
                 'GCA_005524045.1.fna',
                 'Reactor4-bin.4.fna',
                 'POS2015-07-24-bin.16.fna',
                 'GCA_001897745.1.fna',
                 'GCA_002304785.1.fna',
                 'GCA_900089955.1.fna',
                 'GCA_003538495.1.fna')
keep$bin1 <- factor(keep$bin1, levels=c(clade_order))
keep$bin2 <- factor(keep$bin2, levels=c(clade_order))

ani_plot <- keep %>% ggplot(aes(x=bin1, y=bin2, fill=ANI)) + geom_raster() + scale_fill_viridis(option="inferno") + theme(axis.text.x= element_text(angle=85, hjust=1))

ggsave(filename="figs/ANI-comparisons.png", ani_plot, width=20, height=16, units=c("cm"))
