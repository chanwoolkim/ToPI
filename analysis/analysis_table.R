start_time <- Sys.time()

library(boot)
library(DiagrammeR)
library(grf)
library(ivreg)
library(tidyverse)
library(RColorBrewer)
library(ggplot2)
library(xtable)
library(textables)
library(doParallel)
library(doSNOW)
library(snow)
library(doMPI)
library(Rmpi)
library(foreach)

nw <- mpi.universe.size()-1
my_workers <- parallel::makeCluster(nw, type="MPI")
registerDoParallel(my_workers)

seed <- 2022

covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf")
covariates_short <- c("m_iq", "m_age")


# Function to create data frame for output estimates ####
# Input for the program of interest
clean_data <- function(df, subsample) {
  df_output <- df %>%
    filter(!is.na(iq),
           !is.na(D),
           !is.na(alt),
           !is.na(black),
           !is.na(caregiver_home),
           m_edu %in% c(1, 2, 3))
  
  if (subsample) {
    df_output <- df_output %>% filter(black==1, m_edu %in% c(1, 2))
  }
  
  return(df_output)
}

# Now create input for covariates
covariate_selection <- function(df, covariates_list) {
  X <- df %>% select(all_of(covariates_list)) %>% as.matrix()
  return(X)
}

# Causal matrix
causal_matrix <- function(df_from, df_to, program_from, program_to,
                          method="ITT", covariates_list=covariates_all, subsample=FALSE,
                          honesty=FALSE, min.node.size=20) {
  
  df_from <- clean_data(df_from, subsample)
  N <- count(df_from) %>% as.numeric()
  X_from <- covariate_selection(df_from, covariates_list)
  W <- df_from$R
  Y <- df_from$iq
  Z <- df_from$D
  X_to <- covariate_selection(df_to, covariates_list)
  
  # Fit the causal/instrumental forest on the program of interest
  if (method=="ITT") {
    forest <- causal_forest(X_from, Y, W,
                            honesty=honesty, min.node.size=min.node.size, seed=seed)
    fit <- lm(as.formula(paste0("iq~R+",
                                paste(covariates_list, collapse="+"))),
              data=df_from)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X_from, Y, W, Z,
                                  honesty=honesty, min.node.size=min.node.size, seed=seed)
    fit <- ivreg(as.formula(paste0("iq~R+",
                                   paste(covariates_list, collapse="+"),
                                   "|D+",
                                   paste(covariates_list, collapse="+"))),
                 data=df_from)
  }
  
  coefficient=summary(fit)$coefficients[2, 1] %>% as.numeric()
  se=summary(fit)$coefficients[2, 2] %>% as.numeric()
  p_value=summary(fit)$coefficients[2, 4] %>% as.numeric()
  pre_estimate <- mean(forest$predictions)
  pre_dr_estimate <- average_treatment_effect(forest)[[1]]
  pre_dr_se <- average_treatment_effect(forest)[[2]]
  
  # Run bootstrap
  forest_boot <- function(data, index) {
    df_select <- data[index,]
    
    X_select <- df_select %>% select(all_of(covariates_list)) %>% as.matrix()
    W_select <- df_select$R
    Y_select <- df_select$iq
    Z_select <- df_select$D
    
    # Fit the causal/instrumental forest on the program of interest
    if (method=="ITT") {
      forest <- causal_forest(X_select, Y_select, W_select,
                              honesty=honesty, min.node.size=min.node.size, seed=seed)
    } else if (method=="LATE") {
      forest <- instrumental_forest(X_select, Y_select, W_select, Z_select,
                                    honesty=honesty, min.node.size=min.node.size, seed=seed)
    }
    
    to_estimate <- mean(predict(forest, X_to)$predictions)
    return(to_estimate)
  }
  
  output_estimates <- boot(data=df_from,
                           statistic=forest_boot,
                           R=1000,
                           parallel="snow")
  
  pre_dr_p_value <- 2*pnorm(-pre_dr_estimate/pre_dr_se)
  to_p_value <- 2*pnorm(-output_estimates$t0/sd(output_estimates$t))
  
  output <- data.frame(program_from=program_from,
                       program_to=program_to,
                       N=N,
                       coefficient=coefficient,
                       pre_estimate=pre_estimate,
                       pre_dr_estimate=pre_dr_estimate,
                       to_estimate=output_estimates$t0,
                       se=se,
                       pre_dr_se=pre_dr_se,
                       to_se=sd(output_estimates$t),
                       p_value=p_value,
                       pre_dr_p_value=pre_dr_p_value,
                       to_p_value=to_p_value)
  
  if (subsample) {
    output <- output %>%
      add_column(subsample="TRUE", .after="program_to")
  } else {
    output <- output %>%
      add_column(subsample="FALSE", .after="program_to")
  }
  
  return(output)
}

# Variable importance can be run outside bootstrap
variable_importance_matrix <- function(df, program,
                                       covariates_list=covariates_all, subsample=FALSE,
                                       method="ITT", honesty=FALSE, min.node.size=5) {
  df <- clean_data(df, subsample)
  X <- covariate_selection(df, covariates_list)
  W <- df$R
  Y <- df$iq
  Z <- df$D
  
  # Fit the causal/instrumental forest on the program of interest
  if (method=="ITT") {
    forest <- causal_forest(X, Y, W,
                            honesty=honesty, min.node.size=min.node.size, seed=seed)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X, Y, W, Z,
                                  honesty=honesty, min.node.size=min.node.size, seed=seed)
  }
  
  var_importance <- variable_importance(forest)
  result <- left_join(data.frame(covariate=covariates_all),
                      data.frame(covariate=covariates_list,
                                 var_importance=var_importance),
                      by="covariate")
  result <- cbind(result,
                  data.frame(program=program,
                             subsample=subsample,
                             method=method))
  return(result)
}

# Basic regression matrix
regression_matrix <- function(df, program,
                              method="ITT", covariates_list=covariates_all, subsample=FALSE) {
  df_select <- clean_data(df, subsample)
  
  # Fit the (IV) regression on the program of interest
  if (method=="ITT") {
    fit <- lm(as.formula(paste0("iq~R+",
                                paste(covariates_list, collapse="+"))),
              data=df_select)
    output <- data.frame(variable=c("Constant", "R", covariates_list),
                         coefficient=summary(fit)$coefficients[, 1] %>% as.numeric(),
                         se=summary(fit)$coefficients[, 2] %>% as.numeric(),
                         p_value=summary(fit)$coefficients[, 4] %>% as.numeric(),
                         N=nobs(fit))
  } else if (method=="LATE") {
    fit <- ivreg(as.formula(paste0("iq~D+",
                                   paste(covariates_list, collapse="+"),
                                   "|R+",
                                   paste(covariates_list, collapse="+"))),
                 data=df_select)
    output <- data.frame(variable=c("Constant", "D", covariates_list),
                         coefficient=summary(fit)$coefficients[, 1] %>% as.numeric(),
                         se=summary(fit)$coefficients[, 2] %>% as.numeric(),
                         p_value=summary(fit)$coefficients[, 4] %>% as.numeric(),
                         N=nobs(fit))
  }
  
  output_empty <- data.frame(variable=c("R", "D", covariates_list, "Constant"))
  output <- left_join(output_empty, output, by="variable")
  return(output)
}

# Type Prevalence
type_prevalence <- function(df, program, subsample) {
  df <- clean_data(df, subsample)
  N <- count(df)$n
  df_stats <- df %>%
    transmute(none=(D==0 & alt==0),
              participate=D==1,
              other=(D==0 & alt==1),
              R)
  
  stats_1 <- df_stats %>%
    filter(R==1) %>%
    summarise(p_nn=mean(none, na.rm=TRUE),
              p_cc=mean(other, na.rm=TRUE))
  stats_0 <- df_stats %>%
    filter(R==0) %>%
    summarise(p_hh=mean(participate, na.rm=TRUE),
              p_nh=mean(none, na.rm=TRUE),
              p_ch=mean(other, na.rm=TRUE))
  stats <- cbind(stats_1, stats_0) %>%
    mutate(p_nh=p_nh-p_nn,
           p_ch=p_ch-p_cc,
           nh_share=p_nh/(p_nh+p_ch),
           program=program,
           N=N) %>%
    select(program, N, p_nh, p_ch, nh_share, p_hh, p_cc, p_nn)
  return(stats)
}


# Execute! ####
# Load data
programs_ehs <- c("ehsmixed_center", "ehscenter")
programs <- c(programs_ehs, "abc")

for (p in programs_ehs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
                  m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA)) %>%
           rename(iq=ppvt3y))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(D=D_12,
         alt=P_12,
         m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
         m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA),
         caregiver_home=1) %>%
  rename(iq=sb3y)

ehscenter <- ehscenter %>%
  mutate(caregiver_home=caregiver_ever,
         D=D_12,
         alt=P_12,
         H=ifelse(D==1, 4140/6000, ifelse(D==0, 0, NA)))

ehsmixed_center <- ehsmixed_center %>%
  mutate(caregiver_home=caregiver_ever,
         D=D_12,
         alt=P_12,
         H=ifelse(D==1, 4140/6000, ifelse(D==0, 0, NA)))

# Build all output
# Base case
causal_output <- data.frame()
instrumental_output <- data.frame()
variable_importance_output <- data.frame()
regression_output <- data.frame(variable=c("R", "D", covariates_all, "Constant"))
prevalence_output <- data.frame()

for (p in programs_ehs) {
  causal_output <- bind_rows(causal_output,
                             causal_matrix(get(p), abc, p, "abc"))
  instrumental_output <- bind_rows(instrumental_output,
                                   causal_matrix(get(p), abc, p, "abc", method="LATE"))
  variable_importance_output <- bind_rows(variable_importance_output,
                                          variable_importance_matrix(get(p), p))
  variable_importance_output <- bind_rows(variable_importance_output,
                                          variable_importance_matrix(get(p), p,
                                                                     method="LATE"))
  regression_output <- left_join(regression_output,
                                 regression_matrix(get(p), p),
                                 by="variable")
  regression_output <- left_join(regression_output,
                                 regression_matrix(get(p), p, method="LATE"),
                                 by="variable")
  
  causal_output <-
    bind_rows(causal_output,
              causal_matrix(get(p), abc, p, "abc",
                            covariates_list=covariates_short))
  instrumental_output <-
    bind_rows(instrumental_output,
              causal_matrix(get(p), abc, p, "abc",
                            covariates_list=covariates_short,
                            method="LATE"))
  variable_importance_output <-
    bind_rows(variable_importance_output,
              variable_importance_matrix(get(p), p,
                                         covariates_list=covariates_short))
  variable_importance_output <-
    bind_rows(variable_importance_output,
              variable_importance_matrix(get(p), p,
                                         covariates_list=covariates_short,
                                         method="LATE"))
  regression_output <- left_join(regression_output,
                                 regression_matrix(get(p), p,
                                                   covariates_list=covariates_short),
                                 by="variable")
  regression_output <- left_join(regression_output,
                                 regression_matrix(get(p), p,
                                                   covariates_list=covariates_short, 
                                                   method="LATE"),
                                 by="variable")
  
  causal_output <-
    bind_rows(causal_output,
              causal_matrix(get(p), abc, p, "abc",
                            covariates_list=covariates_short, subsample=TRUE))
  instrumental_output <-
    bind_rows(instrumental_output,
              causal_matrix(get(p), abc, p, "abc",
                            covariates_list=covariates_short, subsample=TRUE,
                            method="LATE"))
  variable_importance_output <-
    bind_rows(variable_importance_output,
              variable_importance_matrix(get(p), p,
                                         covariates_list=covariates_short,
                                         subsample=TRUE))
  variable_importance_output <-
    bind_rows(variable_importance_output,
              variable_importance_matrix(get(p), p,
                                         covariates_list=covariates_short,
                                         subsample=TRUE, method="LATE"))
  regression_output <- left_join(regression_output,
                                 regression_matrix(get(p), p,
                                                   covariates_list=covariates_short,
                                                   subsample=TRUE),
                                 by="variable")
  regression_output <- left_join(regression_output,
                                 regression_matrix(get(p), p,
                                                   covariates_list=covariates_short,
                                                   subsample=TRUE, method="LATE"),
                                 by="variable")
}

for (p in programs) {
  prevalence_output <- bind_rows(prevalence_output,
                                 type_prevalence(get(p), p, subsample=FALSE))
  prevalence_output <- bind_rows(prevalence_output,
                                 type_prevalence(get(p), p, subsample=TRUE))
}


# Output to LaTeX tables ####
# Forest output
forest_tex <- function(causal_result, instrumental_result) {
  row_tr <- function(row, se=FALSE) {
    if (se) {
      out <- TR(c(NA, NA,
                  causal_result[row, 9],
                  causal_result[row, 10:11],
                  instrumental_result[row, 9],
                  instrumental_result[row, 10:11]) %>% as.numeric(), se=TRUE, dec=3)
    } else {
      out <- TR(c(causal_result[row, 4:5],
                  causal_result[row, 7:8],
                  instrumental_result[row, 5],
                  instrumental_result[row, 7:8]) %>% as.numeric(),
                pvalues=c(1,
                          causal_result[row, 12],
                          causal_result[row, 13:14],
                          instrumental_result[row, 12],
                          instrumental_result[row, 13:14]) %>% as.numeric(),
                dec=c(0, rep(3, 6)))
    }
    return(out)
  }
  
  tab <- TR(c("", "ITT", "LATE"), cspan=c(2, 3, 3)) +
    midrulep(list(c(3, 5), c(6, 8))) +
    TR(c("Sample/Description", "Obs", "OLS", "Causal Forest", "2SLS", "Instrumental Forest"),
       cspan=c(1, 1, 1, 2, 1, 2)) +
    TR(c("", "$f_X$", "$f_X^{\\text{ABC}}$",
         "", "$f_X$", "$f_X^{\\text{ABC}}$"),
       cspan=c(3, 1, 1, 1, 1, 1)) + midrule() +
    textables::`%:%`(TR(c(NA)),
                     TR(c("", "Programme: EHS, Center $+$ Mixed"), cspan=c(1, 6))) +
    midrulep(list(c(3, 8))) +
    textables::`%:%`(TR("Full/All Xs"), row_tr(1)) +
    row_tr(1, se=TRUE) +
    textables::`%:%`(TR("Full/Key Xs"), row_tr(2)) +
    row_tr(2, se=TRUE) +
    textables::`%:%`(TR("Subsample/Key Xs"), row_tr(3)) +
    row_tr(3, se=TRUE) + midrule() +
    textables::`%:%`(TR(c(NA)),
                     TR(c("", "Programme: EHS, Center Only"), cspan=c(1, 6))) +
    midrulep(list(c(3, 8))) +
    textables::`%:%`(TR("Full/All Xs"), row_tr(4)) +
    row_tr(4, se=TRUE) +
    textables::`%:%`(TR("Full/Key Xs"), row_tr(5)) +
    row_tr(5, se=TRUE) +
    textables::`%:%`(TR("Subsample/Key Xs"), row_tr(6)) +
    row_tr(6, se=TRUE)
  return(tab)
}

tab <- forest_tex(causal_output, instrumental_output)
TS(tab, file="forest_base", header=c('l', rep('c', 7)),
   output_path=output_dir, stand_alone=FALSE)
TS(tab, file="forest_base", header=c('l', rep('c', 7)),
   output_path=output_git, stand_alone=FALSE)
write.csv(causal_output,
          file=paste0(output_git, "causal_output.csv"),
          row.names=FALSE)
write.csv(instrumental_output,
          file=paste0(output_git, "instrumental_output.csv"),
          row.names=FALSE)

# Type prevalence output
prevalence_tex <- function(prevalence_result) {
  row_tr <- function(row) {
    out <- TR(prevalence_result[row, 2:8] %>% as.numeric(),
              dec=c(0, rep(3, 6)))
    return(out)
  }
  
  tab <- TR(c("", "Compliers", "", "Always-Takers"), cspan=c(2, 2, 1, 3)) +
    midrulep(list(c(3, 4), c(6, 8))) +
    TR(c("Sample", "Obs",
         "$p_{nh}$", "$p_{ch}$", "$nh$-share", "$p_{hh}$", "$p_{cc}$", "$p_{nn}$")) +
    midrule() +
    textables::`%:%`(TR(c(NA)),
                     TR(c("", "Programme: EHS, Center $+$ Mixed"), cspan=c(1, 6))) +
    midrulep(list(c(3, 8))) +
    textables::`%:%`(TR("Full"), row_tr(1)) +
    textables::`%:%`(TR("Subsample"), row_tr(2)) +
    midrule() +
    textables::`%:%`(TR(c(NA)),
                     TR(c("", "Programme: EHS, Center Only"), cspan=c(1, 6))) +
    midrulep(list(c(3, 8))) +
    textables::`%:%`(TR("Full"), row_tr(3)) +
    textables::`%:%`(TR("Subsample"), row_tr(4)) +
    midrule() +
    textables::`%:%`(TR(c(NA)),
                     TR(c("", "Programme: ABC"), cspan=c(1, 6))) +
    midrulep(list(c(3, 8))) +
    textables::`%:%`(TR("Full"), row_tr(5)) +
    textables::`%:%`(TR("Subsample"), row_tr(6))
  return(tab)
}

tab <- prevalence_tex(prevalence_output)
TS(tab, file="type_prevalence", header=c('l', rep('c', 7)),
   output_path=output_dir, stand_alone=FALSE)
TS(tab, file="type_prevalence", header=c('l', rep('c', 7)),
   output_path=output_git, stand_alone=FALSE)
write.csv(prevalence_output,
          file=paste0(output_git, "prevalence_output.csv"),
          row.names=FALSE)

end_time <- Sys.time()
end_time-start_time
