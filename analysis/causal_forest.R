start_time <- Sys.time()

library(boot)
library(DiagrammeR)
library(grf)
library(tidyverse)
library(xtable)

seed <- 9657

covariates_all <- c("m_iq", "black", "sex", "m_age", "m_edu_2", "m_edu_3", "sibling", "gestage", "mf")
covariates_chopped_all <- c("m_iq", "sex", "m_age", "sibling", "gestage", "mf")
covariates_short <- c("m_iq", "m_age")


# Function to create data frame for causal forest estimates ####
causal_matrix <- function(df, output_var, program,
                          method="ATE", covariates_list="all", chopped=FALSE) {
  
  # Input for the program of interest
  df <- df %>%
    filter(!is.na(!!(sym(output_var))),
           !is.na(D),
           !is.na(alt),
           !is.na(black),
           !is.na(caregiver_home),
           m_edu %in% c(1, 2, 3))
  
  if (chopped) {
    df <- df %>% filter(black==1, m_edu %in% c(1, 2))
  }
  
  N <- count(df) %>% as.numeric()
  
  # Now create input for ABC and covariates
  if (covariates_list=="all") {
    X <- df %>% select(all_of(covariates_all)) %>% as.matrix()
    X_abc <- abc %>% select(all_of(covariates_all)) %>% as.matrix()
  } else if (covariates_list=="chopped_all") {
    X <- df %>% select(all_of(covariates_chopped_all)) %>% as.matrix()
    X_abc <- abc %>% select(all_of(covariates_chopped_all)) %>% as.matrix()
  } else if (covariates_list=="short") {
    X <- df %>% select(all_of(covariates_short)) %>% as.matrix()
    X_abc <- abc %>% select(all_of(covariates_short)) %>% as.matrix()
  }
  
  # Variable importance can be run outside bootstrap
  W <- df$R
  Y <- df %>% pull(output_var)
  Z <- df$D
  
  # Fit the causal/instrumental forest on the program of interest
  if (method=="ATE") {
    forest <- causal_forest(X, Y, W,
                            honesty=FALSE, min.node.size=20, seed=seed)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X, Y, W, Z,
                                  honesty=FALSE, min.node.size=20, seed=seed)
  }
  
  var_importance <- variable_importance(forest)
  
  # Run bootstrap
  forest_boot <- function(data, index) {
    df_select <- data[index,]
    
    if (covariates_list=="all") {
      X <- df_select %>% select(all_of(covariates_all)) %>% as.matrix()
    } else if (covariates_list=="chopped_all") {
      X <- df_select %>% select(all_of(covariates_chopped_all)) %>% as.matrix()
    } else if (covariates_list=="short") {
      X <- df_select %>% select(all_of(covariates_short)) %>% as.matrix()
    }
    
    W <- df_select$R
    Y <- df_select %>% pull(output_var)
    Z <- df_select$D
    
    # Fit the causal/instrumental forest on the program of interest
    if (method=="ATE") {
      forest <- causal_forest(X, Y, W,
                              honesty=FALSE, min.node.size=20, seed=seed)
    } else if (method=="LATE") {
      forest <- instrumental_forest(X, Y, W, Z,
                                    honesty=FALSE, min.node.size=20, seed=seed)
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
  
  pre_dr_p_value <- 2*pnorm(-output_estimates$t0[2]/output_estimates$t0[3])
  abc_p_value <- 2*pnorm(-output_estimates$t0[4]/sd(output_estimates$t[,4]))
  
  if (covariates_list=="all") {
      output <- data.frame(program=program,
                           output_var=output_var,
                           covariates_list=covariates_list,
                           pre_estimate=output_estimates$t0[1],
                           pre_dr_estimate=output_estimates$t0[2],
                           pre_dr_se=output_estimates$t0[3],
                           pre_dr_p_value=pre_dr_p_value,
                           abc_estimate=output_estimates$t0[4],
                           abc_se=sd(output_estimates$t[,4]),
                           abc_p_value=abc_p_value,
                           m_iq_importance=var_importance[1],
                           black_importance=var_importance[2],
                           sex_importance=var_importance[3],
                           m_age_importance=var_importance[4],
                           m_edu_2_importance=var_importance[5],
                           m_edu_3_importance=var_importance[6],
                           sibling_importance=var_importance[7],
                           gestage_importance=var_importance[8],
                           mf_importance=var_importance[9],
                           N=N)
    } else if (covariates_list=="chopped_all") {
      output <- data.frame(program=program,
                           output_var=output_var,
                           covariates_list=covariates_list,
                           pre_estimate=output_estimates$t0[1],
                           pre_dr_estimate=output_estimates$t0[2],
                           pre_dr_se=output_estimates$t0[3],
                           pre_dr_p_value=pre_dr_p_value,
                           abc_estimate=output_estimates$t0[4],
                           abc_se=sd(output_estimates$t[,4]),
                           abc_p_value=abc_p_value,
                           m_iq_importance=var_importance[1],
                           sex_importance=var_importance[3],
                           m_age_importance=var_importance[4],
                           sibling_importance=var_importance[7],
                           gestage_importance=var_importance[8],
                           mf_importance=var_importance[9],
                           N=N)
    } else if (covariates_list=="short") {
      output <- data.frame(program=program,
                           output_var=output_var,
                           covariates_list=covariates_list,
                           pre_estimate=output_estimates$t0[1],
                           pre_dr_estimate=output_estimates$t0[2],
                           pre_dr_se=output_estimates$t0[3],
                           pre_dr_p_value=pre_dr_p_value,
                           abc_estimate=output_estimates$t0[4],
                           abc_se=sd(output_estimates$t[,4]),
                           abc_p_value=abc_p_value,
                           m_iq_importance=var_importance[1],
                           m_age_importance=var_importance[2],
                           N=N)
  }
  
  if (chopped) {
    output <- output %>%
      add_column(chopped="TRUE", .after="covariates_list")
  } else {
    output <- output %>%
      add_column(chopped="FALSE", .after="covariates_list")
  }
  
  return(output)
}


# Execute! ####
# Load data
programs <- c("ehscenter", "ehsmixed_center") #, "ihdp")

for (p in programs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
                  m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA)))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
         m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA))

ehscenter <- ehscenter %>%
  mutate(caregiver_home=caregiver_ever,
         D=D_18,
         alt=P_18)

ehsmixed_center <- ehsmixed_center %>%
  mutate(caregiver_home=caregiver_ever,
         D=D_18,
         alt=P_18)

ehscenter_output <- c("ppvt3y")
ehsmixed_center_output <- c("ppvt3y")
#ihdp_output <- c("ppvt3y", "sb3y")
abc_output <- c("sb3y")

# Output to LaTeX table
output_to_table <- function(df, forest_type="causal", table_type="main") {
  file_name <- paste0(forest_type, "_output_", table_type, ".tex")
  
  if (table_type=="main") {
    df_select <- df %>%
      select('Program'=program,
             'Outcome'=output_var,
             'Covariates'=covariates_list,
             'Chopped'=chopped,
             'Pre-Estimate'=pre_estimate,
             'Pre-DR-Estimate'=pre_dr_estimate,
             'Pre-DR-SE'=pre_dr_se,
             'Pre-DR-p-Value'=pre_dr_p_value,
             'ABC-Estimate'=abc_estimate,
             'ABC-SE'=abc_se,
             'ABC-p-Value'=abc_p_value,
             'N'=N)
  } else if (table_type=="importance") {
    df_select <- df %>%
      select('Program'=program,
             'Outcome'=output_var,
             'Covariates'=covariates_list,
             'Chopped'=chopped,
             'Mother IQ'=m_iq_importance,
             'Black'=black_importance,
             'Sex'=sex_importance,
             'Mother Age'=m_age_importance,
             'Mother Edu_2'=m_edu_2_importance,
             'Mother Edu_3'=m_edu_3_importance,
             'Sibling'=sibling_importance,
             'Gestational Age'=gestage_importance,
             'Father'=mf_importance,
             'N'=N)
  }
  digits_vec <- c(rep(0, 5), rep(3, ncol(df_select)-5), 0)
  
  print(xtable(df_select, digits=digits_vec, table.placement="H"),
        include.rownames=FALSE,
        comment=FALSE,
        file=paste0(output_dir, file_name))
  
  print(xtable(df_select, digits=digits_vec, table.placement="H"),
        include.rownames=FALSE,
        comment=FALSE,
        file=paste0(output_overleaf, file_name))
}

# Empty data
data_empty <- function() {
  df <- data.frame(program=NULL,
                   output_var=NULL,
                   covariates_list=NULL,
                   chopped=NULL,
                   pre_estimate=NULL,
                   pre_dr_estimate=NULL,
                   pre_dr_se=NULL,
                   pre_dr_p_value=NULL,
                   abc_estimate=NULL,
                   abc_se=NULL,
                   abc_p_value=NULL,
                   m_iq_importance=NULL,
                   black_importance=NULL,
                   sex_importance=NULL,
                   m_age_importance=NULL,
                   m_edu_2_importance=NULL,
                   m_edu_3_importance=NULL,
                   sibling_importance=NULL,
                   gestage_importance=NULL,
                   mf_importance=NULL,
                   N=NULL)
  
  return(df)
}

# Causal forest
causal_output <- data_empty()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output <-
      bind_rows(causal_output,
                causal_matrix(get(p), v, p))
  }
}

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output <-
      bind_rows(causal_output,
                causal_matrix(get(p), v, p,
                              covariates_list="short"))
  }
}

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output <-
      bind_rows(causal_output,
                causal_matrix(get(p), v, p,
                              covariates_list="chopped_all", chopped=TRUE))
  }
}

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output <-
      bind_rows(causal_output,
                causal_matrix(get(p), v, p,
                              covariates_list="short", chopped=TRUE))
  }
}

write.csv(causal_output,
          paste0(data_dir, "causal_forest.csv"), row.names=FALSE)

output_to_table(causal_output)
output_to_table(causal_output, table_type="importance")

# Instrumental forest
instrumental_output <- data_empty()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output <-
      bind_rows(instrumental_output,
                causal_matrix(get(p), v, p,
                              method="LATE"))
  }
}

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output <-
      bind_rows(instrumental_output,
                causal_matrix(get(p), v, p,
                              method="LATE", covariates_list="short"))
  }
}

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output <-
      bind_rows(instrumental_output,
                causal_matrix(get(p), v, p,
                              method="LATE", covariates_list="chopped_all", chopped=TRUE))
  }
}

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output <-
      bind_rows(instrumental_output,
                causal_matrix(get(p), v, p,
                              method="LATE", covariates_list="short", chopped=TRUE))
  }
}

write.csv(instrumental_output,
          paste0(data_dir, "instrumental_forest.csv"), row.names=FALSE)

output_to_table(instrumental_output, forest_type="instrumental")
output_to_table(instrumental_output, forest_type="instrumental", table_type="importance")

end_time <- Sys.time()
end_time-start_time
