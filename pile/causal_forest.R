rm(list=ls())
start_time <- Sys.time()

library(boot)
library(DiagrammeR)
library(grf)
library(tidyverse)
library(xtable)

data_dir <- "C:/Users/561CO/Dropbox/Research/TOPI/working/"
output_dir <- "C:/Users/561CO/Dropbox/Research/TOPI/do-ToPI/output_backup/"
output_overleaf <- "C:/Users/561CO/Dropbox/Apps/Overleaf/ToPI/Results/"
seed <- 9657

covariate_names <- c("m_iq", "black", "sex", "m_age", "m_edu_2", "m_edu_3", "bw")


# Function to create data frame for causal forest estimates ####
causal_matrix <- function(df, output_var, program, method="ATE") {
  # Input for the program of interest
  df <- df %>%
    filter(!is.na(!!(sym(output_var))),
           !is.na(D),
           !is.na(black),
           !is.na(caregiver_home),
           m_edu %in% c(1, 2, 3))
  
  # Now create input for ABC
  # Pull out SB even when the program of interest has PPVT
  if (output_var %in% c("sb3y", "ppvt3y")) {
    df_abc <- abc %>%
      filter(!is.na(sb3y),
             !is.na(D))
  } else {
    df_abc <- abc %>%
      filter(!is.na(!!(sym(output_var))),
             !is.na(D))
  }
  
  X_abc <- df_abc %>% select(covariate_names) %>% as.matrix()
  
  # Variable importance can be run outside bootstrap
  X <- df %>% select(covariate_names) %>% as.matrix()
  W <- df$R
  Y <- df %>% pull(output_var)
  Z <- df$D
  
  # Fit the causal/instrumental forest on the program of interest
  if (method=="ATE") {
    forest <- causal_forest(X, Y, W, honesty=FALSE, min.node.size=20, seed=seed)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X, Y, W, Z, honesty=FALSE, min.node.size=20, seed=seed)
  }
  
  var_importance <- variable_importance(forest)
  
  # Run bootstrap
  forest_boot <- function(data, index) {
    df_select <- data[index,]
    X <- df_select %>% select(covariate_names) %>% as.matrix()
    W <- df_select$R
    Y <- df_select %>% pull(output_var)
    Z <- df_select$D
    
    # Fit the causal/instrumental forest on the program of interest
    if (method=="ATE") {
      forest <- causal_forest(X, Y, W, honesty=FALSE, min.node.size=20, seed=seed)
    } else if (method=="LATE") {
      forest <- instrumental_forest(X, Y, W, Z, honesty=FALSE, min.node.size=20, seed=seed)
    }
    
    pre_estimate <- mean(forest$predictions)
    pre_dr_estimate <- average_treatment_effect(forest)[[1]]
    pre_dr_se <- average_treatment_effect(forest)[[2]]
    abc_estimate <- mean(predict(forest, X_abc)$predictions)
    
    output <- c(pre_estimate,
                pre_dr_estimate, pre_dr_se,
                abc_estimate)
    
    return(output)
  }
  
  output_estimates <- boot(data=df,
                           statistic=forest_boot,
                           R=1000)
  
  output <- data.frame(program=program,
                       output_var=output_var,
                       pre_estimate=output_estimates$t0[1],
                       pre_dr_estimate=output_estimates$t0[2],
                       pre_dr_se=output_estimates$t0[3],
                       abc_estimate=output_estimates$t0[4],
                       abc_se=sd(output_estimates$t[,4]),
                       m_iq_importance=var_importance[1],
                       black_importance=var_importance[2],
                       sex_importance=var_importance[3],
                       m_age_importance=var_importance[4],
                       m_edu_2_importance=var_importance[5],
                       m_edu_3_importance=var_importance[6],
                       bw_importance=var_importance[7])
  return(output)
}


# Execute! ####
programs <- c("ehscenter", "ehsmixed_center", "ihdp")

for (p in programs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=m_edu==2,
                  m_edu_3=m_edu==3))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(twin=0,
         m_edu_2=m_edu==2,
         m_edu_3=m_edu==3)

ehscenter_output <- c("ppvt3y")
ehsmixed_center_output <- c("ppvt3y")
ihdp_output <- c("ppvt3y", "sb3y")
abc_output <- c("sb3y")

causal_output <- data.frame(program=NULL,
                            output_var=NULL,
                            pre_estimate=NULL,
                            pre_dr_estimate=NULL,
                            pre_dr_se=NULL,
                            abc_estimate=NULL,
                            abc_se=NULL,
                            m_iq_importance=NULL,
                            black_importance=NULL,
                            sex_importance=NULL,
                            m_age_importance=NULL,
                            m_edu_2_importance=NULL,
                            m_edu_3_importance=NULL,
                            bw_importance=NULL)

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output <- rbind(causal_output,
                           causal_matrix(get(p), v, p))
  }
}

write.csv(causal_output, paste0(data_dir, "causal_forest.csv"), row.names=FALSE)

causal_output_main <- causal_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Pre-Estimate'=pre_estimate,
         'Pre-DR-Estimate'=pre_dr_estimate,
         'Pre-DR-SE'=pre_dr_se,
         'ABC-Estimate'=abc_estimate,
         'ABC-SE'=abc_se)

print(xtable(causal_output_main,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"causal_forest_output.tex"))

print(xtable(causal_output_main,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_overleaf,"causal_forest_output.tex"))

causal_output_importance <- causal_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Mother IQ'=m_iq_importance,
         'Black'=black_importance,
         'Sex'=sex_importance,
         'Mother Age'=m_age_importance,
         'Mother Edu_2'=m_edu_2_importance,
         'Mother Edu_3'=m_edu_3_importance,
         'Birth Weight'=bw_importance)

print(xtable(causal_output_importance,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"causal_forest_importance_output.tex"))

print(xtable(causal_output_importance,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_overleaf,"causal_forest_importance_output.tex"))

instrumental_output <- data.frame(program=NULL,
                                  output_var=NULL,
                                  pre_estimate=NULL,
                                  pre_dr_estimate=NULL,
                                  pre_dr_se=NULL,
                                  abc_estimate=NULL,
                                  abc_se=NULL,
                                  m_iq_importance=NULL,
                                  black_importance=NULL,
                                  sex_importance=NULL,
                                  m_age_importance=NULL,
                                  m_edu_2_importance=NULL,
                                  m_edu_3_importance=NULL,
                                  bw_importance=NULL)

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output <- rbind(instrumental_output,
                                 causal_matrix(get(p), v, p, "LATE"))
  }
}

write.csv(instrumental_output, paste0(data_dir, "instrumental_forest.csv"), row.names=FALSE)

instrumental_output_main <- instrumental_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Pre-Estimate'=pre_estimate,
         'Pre-DR-Estimate'=pre_dr_estimate,
         'Pre-DR-SE'=pre_dr_se,
         'ABC-Estimate'=abc_estimate,
         'ABC-SE'=abc_se)

print(xtable(instrumental_output_main,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"instrumental_forest_output.tex"))

print(xtable(instrumental_output_main,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_overleaf,"instrumental_forest_output.tex"))

instrumental_output_importance <- instrumental_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Mother IQ'=m_iq_importance,
         'Black'=black_importance,
         'Sex'=sex_importance,
         'Mother Age'=m_age_importance,
         'Mother Edu_2'=m_edu_2_importance,
         'Mother Edu_3'=m_edu_3_importance,
         'Birth Weight'=bw_importance)

print(xtable(instrumental_output_importance,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"instrumental_forest_importance_output.tex"))

print(xtable(instrumental_output_importance,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_overleaf,"instrumental_forest_importance_output.tex"))

end_time <- Sys.time()
end_time-start_time
