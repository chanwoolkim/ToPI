library(tidyverse)
library(grf)

data_dir <- "C:/Users/56±³À°/Dropbox/Research/TOPI/working/"

# Function to create data frame for causal forest estimates
causal_matrix <- function(df, output_var, program) {
  df <- df %>%
    filter(!is.na(!!(sym(output_var))))
  
  n <- nrow(df)
  p <- 10
  X <- matrix(c(df$bw,
                df$twin,
                df$m_age,
                df$m_edu,
                df$sibling,
                df$m_iq,
                df$black,
                df$sex,
                df$gestage,
                df$mf), n, p)
  W <- df$R
  Y <- df %>% pull(output_var)
  
  c.forest <- causal_forest(X, Y, W)
  c.ate <- average_treatment_effect(c.forest)
  c.vi <- variable_importance(c.forest)
  
  output <- data.frame(program=program,
                       output_var=output_var,
                       ate=c.ate[[1]],
                       ate_error=c.ate[[2]],
                       vi_bw=c.vi[[1]],
                       vi_twin=c.vi[[2]],
                       vi_m_age=c.vi[[3]],
                       vi_m_edu=c.vi[[4]],
                       vi_sibling=c.vi[[5]],
                       vi_m_iq=c.vi[[6]],
                       vi_black=c.vi[[7]],
                       vi_sex=c.vi[[8]],
                       vi_gestage=c.vi[[9]],
                       vi_mf=c.vi[[10]])
  
  return(output)
}

# Execute!
ehscenter <- read.csv(paste0(data_dir,"ehscenter-topi.csv"))
ihdp <- read.csv(paste0(data_dir,"ihdp-topi.csv"))
abc <- read.csv(paste0(data_dir,"abc-topi.csv"))

output <- data.frame(program=NULL,
                     ate=NULL,
                     ate_error=NULL,
                     vi_bw=NULL,
                     vi_twin=NULL,
                     vi_m_age=NULL,
                     vi_m_edu=NULL,
                     vi_sibling=NULL,
                     vi_m_iq=NULL,
                     vi_black=NULL,
                     vi_sex=NULL,
                     vi_gestage=NULL,
                     vi_mf=NULL)

ehscenter_output <- c("norm_home_learning3y", "norm_home_total3y", "home3y_original")
ihdp_output <- c("norm_home_learning3y", "norm_home_total3y", "home3y_original", "home_jbg_learning")
abc_output <- c("norm_home_learning3y", "norm_home_total3y", "home3y6m_original", "home_jbg_learning")

for (v in ehscenter_output) {
  output <- rbind(output,
                  causal_matrix(ehscenter, v, "ehscenter"))
}

for (v in ihdp_output) {
  output <- rbind(output,
                  causal_matrix(ihdp, v, "ihdp"))
}

for (v in abc_output) {
  output <- rbind(output,
                  causal_matrix(abc, v, "abc"))
}

output <- output %>%
  mutate(lower_ci=ate-qnorm(0.975)*ate_error,
         upper_ci=ate+qnorm(0.975)*ate_error)

write.csv(output, paste0(data_dir, "causal_forest.csv"), row.names=FALSE)

output_edit <- output %>%
  mutate(numCF=1:11) %>%
  select(numCF,
         coeffCF=ate,
         lowerCF=lower_ci,
         upperCF=upper_ci)

write.csv(output_edit, paste0(data_dir, "causal_forest_edit.csv"), row.names=FALSE)

