rm(list=ls())

wd <- paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/../..")
data_dir <- paste0(wd, "/working/")
output_dir <- paste0(wd, "/../../Apps/Overleaf/ToPI/EHStoABC/Results/")
output_git <- paste0(wd, "/code/output_backup/")

library(boot)
library(DiagrammeR)
library(grf)
library(ivreg)
library(tidyverse)
library(RColorBrewer)
library(ggplot2)
library(xtable)
library(textab)
library(doParallel)
library(doSNOW)
library(snow)
library(foreach)

seed <- 2024