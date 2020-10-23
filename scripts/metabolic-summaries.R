library(tidyverse)
library(reshape2)

summaries <- read.csv("results/metabolic_reconstructions/cleaned-matrix.csv")
metadata <- read.csv("results/stats/POS-MAGs-final-stats.csv") %>% select(bin, code, classification)

colnames(summaries)[1] <- c("bin")
metadata$bin <- gsub("-", "_", metadata$bin)
summary_table <- left_join(metadata, summaries)
write.csv(summary_table, "results/metabolic_reconstructions/metabolic_summaries_table.csv", quote=FALSE, row.names=FALSE)

selectedTraits <- read.csv("results/metabolic_reconstructions/metabolic_summaries_table_edited.csv")
colnames(selectedTraits) <- c("Bin", "Code", "Classification", "hao", "pmoA", "pmoB", "pmoC", "nirB", "nirD", "nirK", "narGZ", "nosZ", "nosD", "aprA", "aprB", "sat", "dsrA", "dsrB", "nifD", "nifH", "nifK", "phbB", "phbA", "phbC", "phaZ", "ppk1", "pstB", "pstC", "pstA", "phoU", "pstS", "pit", "soxA", "soxX", "soxB", "soxC", "soxY","soxZ", "soxD")
selectedTraits$pstABCS <- (selectedTraits$pstA + selectedTraits$pstB + selectedTraits$pstC + selectedTraits$pstS) / 4
selectedTraits$phbABC <- (selectedTraits$phbA + selectedTraits$phbB + selectedTraits$phbC) / 3

traits <- selectedTraits %>% 
  select(-pmoA, -pmoB, -pmoC, -aprA, -aprB, -sat, -pstA, -pstB, -pstC, -pstS, -phbA, -phbB, -phbC)

traits_modified <- traits %>% select(Code, hao, nirB, nirD, nirK, narGZ, nosZ, nosD, nifD, nifH, nifK, pstABCS, phoU, ppk1, pit, phbABC, phaZ, dsrA, dsrB, soxA, soxB, soxC, soxD, soxX, soxY, soxZ)

trait_table <- as.data.frame(lapply(traits_modified[2:26], function(x) ifelse(x<1, 0, x)))

final_table <- as.data.frame(cbind(bin_order, trait_table))
colnames(final_table)[1] <- c("Code")

bin_order <- c('ACIDO1',
               'ACIDO2',
               'ARMA1',
               'BACT1',
               'BACT3',
               'BACT2',
               'CHIT1',
               'CHIT2',
               'CHIT3',
               'CHIT4',
               'CHIT6',
               'CHIT5',
               'CHIT7',
               'CHIT8',
               'CHIT9',
               'CYTO1',
               'CYTO2',
               'FLAVO2',
               'FLAVO1',
               'FLAVO3',
               'IGNAVI1',
               'IGNAVI2',
               'IGNAVI3',
               'KAPA1',
               'RHODO1',
               'DELTA1',
               'DELTA2',
               'DELTA3',
               'DELTA4',
               'ANAER1',
               'ANAER2',
               'ANAER4',
               'ANAER3',
               'ANAER5',
               'LEPTO1',
               'OBS1',
               'DELTA5',
               'PLANC1',
               'PLANC2',
               'PLANC3',
               'PLANC4',
               'PLANC5',
               'ALPHA1',
               'CAULO2',
               'CAULO1',
               'CAULO3',
               'CAULO4',
               'MICAV1',
               'RHIZO1',
               'RHODOB1',
               'RICK1',
               'RICK2',
               'SPHING2',
               'SPHING1',
               'ALPHA2',
               'OTTO1',
               'RUBRI1',
               'RUBRI2',
               'VITR1',
               'BURK1',
               'BURK2',
               'CAPIIB',
               'CAPIID',
               'CAPIIF',
               'CAPIA',
               'CAPIIA',
               'CAPIIC',
               'DECH1',
               'SULF1',
               'THAU1',
               'ZOOG2',
               'ZOOG1',
               'PARA1',
               'GAMMA1',
               'RHODAN1',
               'AQUI1',
               'LYSO1',
               'PSEUDO1',
               'THERMO2',
               'THERMO1',
               'SPIRO1',
               'SPIRO2',
               'VERUCCO2',
               'VERRUCO1',
               'VERUCCO3',
               'VERUCCO4')

traits.melted <- melt(final_table, id.vars="Code") %>% mutate(Code=factor(Code), Code=factor(Code, levels=c(bin_order)))

traits.melted %>% ggplot(aes(x=Code, y=fct_rev(variable), fill=value)) + geom_tile(color="black", size=0.5, aes(width=1, height=1)) + coord_fixed() + theme(axis.text.x.bottom = element_text(angle=80, hjust=0.95, face="bold"), axis.text.y.left = element_text(face="italic"), axis.ticks.y=element_blank())
  