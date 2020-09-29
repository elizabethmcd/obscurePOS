library(tidyverse)
library(patchwork)

# dissolved oxygen over phases

DO <- read.csv("metadata/dissolvedOxygen_data.csv") %>% select(Cycle, O2...End.of.Cycle)
colnames(DO) <- c("cycle", "DO_end")

DO_plot <- DO %>% ggplot(aes(x=cycle, y=DO_end)) + geom_line(size=2, colour="#0983C4") + scale_x_continuous(breaks=seq(0,130, by=5), expand=c(0,0), limits=c(0,130)) + geom_vline(xintercept=87, linetype="dotted", size=1) + theme_classic()
DO_plot
DO_transparent <- DO_plot + 
  theme(
  panel.background = element_rect(fill = "transparent"), # bg of the panel
  plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
  panel.grid.major = element_blank(), # get rid of major grid
  panel.grid.minor = element_blank(), # get rid of minor grid
  legend.background = element_rect(fill = "transparent"), # get rid of legend bg
  legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
)

PN_removal <- read.csv("metadata/nitrogen_and_phosphorus_removal.csv") 
colnames(PN_removal) <- c("date", "cycle", "p_removed", "n_removed")

PN_plot <- PN_removal %>% ggplot(aes(x=cycle)) + geom_line(aes(y=p_removed), colour="#3B3A77", size=2) + geom_line(aes(y=n_removed), colour="#098098", size=2) + scale_x_continuous(breaks=seq(0,130, by=5), expand=c(0,0), limits=c(0,130))  + geom_vline(xintercept=87, linetype="dotted", size=1) + theme_classic()
PN_plot
PN_transparent <- PN_plot + theme(
  panel.background = element_rect(fill = "transparent"), # bg of the panel
  plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
  panel.grid.major = element_blank(), # get rid of major grid
  panel.grid.minor = element_blank(), # get rid of minor grid
  legend.background = element_rect(fill = "transparent"), # get rid of legend bg
  legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
)
DO_transparent
ggsave("figs/PN_removal.png", PN_transparent, width=20, height=10, units=c("cm"),bg="transparent")
ggsave("figs/DO_profiles.png", DO_transparent, width=20, height=10, units=c("cm"),bg="transparent")

DO_PN <- DO_transparent / PN_transparent

DO_PN_transp <- DO_PN + theme(
  panel.background = element_rect(fill = "transparent"), # bg of the panel
  plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
  panel.grid.major = element_blank(), # get rid of major grid
  panel.grid.minor = element_blank(), # get rid of minor grid
  legend.background = element_rect(fill = "transparent"), # get rid of legend bg
  legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
)

ggsave("figs/DO_PN_profiles.png", DO_PN_transp, width=20, height=12, units=c("cm"),bg="transparent")
