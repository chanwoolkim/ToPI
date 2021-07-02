#install.packages("devtools")
#library(devtools)
#devtools::install_github("susanathey/causalTree", INSTALL_opts="--no-multiarch")

library(causalTree)
library(tidyverse)

data_dir <- "C:/Users/561CO/Dropbox/Research/TOPI/working/"
seed <- 9657

covariate_names <- c("bw", "twin", "m_age", "m_edu", "sibling", "m_iq", "black", "sex", "gestage", "mf")

causal_matrix <- function(program, output_var, program_name) {
  formula_ct <- paste(output_var, "~", paste(covariate_names, collapse=" + "))
  causal_tree <- causalTree(formula_ct,
                            data=program,
                            treatment=program$R,
                            split.Rule="CT",
                            split.Honest=FALSE,
                            cv.option="CT",
                            cv.Honest=FALSE)
  
  causal_estimate <- mean(predict(causal_tree))
  causal_estimate_abc <- mean(predict(causal_tree, newdata=abc))
  
  output_row <- data.frame(program=program_name,
                           output_var=output_var,
                           pre_estimate=causal_estimate,
                           abc_estimate=causal_estimate_abc)
  output_row
}

# Execute!
ehscenter <- read.csv(paste0(data_dir,"ehscenter-topi.csv"))
ihdp <- read.csv(paste0(data_dir,"ihdp-topi.csv"))
abc <- read.csv(paste0(data_dir,"abc-topi.csv")) %>%
  mutate(twin=0)

output <- data.frame(program=NULL,
                     output_var=NULL,
                     pre_estimate=NULL,
                     estimate=NULL)

ehscenter_output <- c("norm_home_learning3y", "norm_home_total3y", "ppvt3y") #, "home3y_original")
ihdp_output <- c("norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "ppvt3y", "sb3y") #, "home3y_original")
abc_output <- c("norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "sb3y") #, "home3y_original")

for (v in ehscenter_output) {
  output <- rbind(output, causal_matrix(ehscenter, v, "ehscenter"))
}

for (v in ihdp_output) {
  output <- rbind(output, causal_matrix(ihdp, v, "ihdp"))
}

write.csv(output, paste0(data_dir, "causal_tree.csv"), row.names=FALSE)
