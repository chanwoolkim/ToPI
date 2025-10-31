rm(list=ls())

wd <- paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/../..")
data_dir <- paste0(wd, "/working/")
output_dir <- paste0(wd, "/../../Apps/Overleaf/ToPI/EHStoABC/Results/")
output_git <- paste0(wd, "/code/output_backup/")

library(AER)
library(boot)
library(boot.pval)
library(DiagrammeR)
library(dplyr)
library(doParallel)
library(doSNOW)
library(foreach)
library(ggplot2)
library(grf)
library(ivreg)
library(leebounds)
library(purrr)
library(RColorBrewer)
library(readr)
library(snow)
library(stringr)
library(textab)
library(tibble)
library(tidyr)
library(tidyverse)
library(xtable)

seed <- 2024
NCPUS <- max(1, parallel::detectCores(logical=TRUE)-1)

source(paste0(wd, "/code/analysis/FRA.R"))

colours_set <- brewer.pal("Set2", n=8)

fte_theme <- function() {
  # Generate the colours for the chart procedurally with RColorBrewer
  palette <- brewer.pal("Greys", n=9)
  color.background="white"
  color.grid.major=palette[3]
  color.axis.text=palette[7]
  color.axis.title=palette[7]
  color.title=palette[9]
  
  # Begin construction of chart
  theme_bw(base_size=12, base_family="serif") +
    
    # Set the entire chart region to a light gray color
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    
    # Format the grid
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25)) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    
    # Format the legend
    theme(legend.position="bottom") +
    theme(legend.background=element_rect(fill=color.background)) +
    theme(legend.title=element_blank()) +
    theme(legend.text=element_text(size=14, color=color.axis.title, family="serif")) +
    theme(legend.box.background=element_rect(colour=color.grid.major)) +
    theme(legend.title.align=0.5) +
    
    # Set title and axis labels, and format these and tick marks
    theme(axis.text=element_text(size=rel(1), color=color.axis.text)) +
    theme(axis.title.x=element_text(color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(color=color.axis.title, vjust=1.25)) +
    
    # Plot margins
    theme(plot.margin=unit(c(0.35, 0.2, 0.3, 0.35), "cm"))
}

