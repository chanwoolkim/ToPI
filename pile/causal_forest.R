rm(list=ls())
start_time <- Sys.time()

library(boot)
library(DiagrammeR)
library(grf)
library(tidyverse)
library(xtable)

data_dir <- "C:/Users/561CO/Dropbox/Research/TOPI/working/"
output_dir <- "C:/Users/561CO/Dropbox/Research/TOPI/do-TOPI/output_backup/"
output_overleaf <- "C:/Users/561CO/Dropbox/Apps/Overleaf/ToPI/Results/"
seed <- 9657

covariates_all <- c("m_iq", "black", "sex", "m_age", "m_edu_2", "m_edu_3", "sibling", "gestage", "mf")
covariates_small <- c("m_iq", "black", "sex", "m_age", "m_edu_2", "m_edu_3", "sibling", "gestage", "mf", "bw")
covariates_short <- c("m_iq", "m_age")
covariates_short_small <- c("m_iq", "m_age", "bw")


# Function to create data frame for causal forest estimates ####
causal_matrix <- function(df, output_var, program,
                          method="ATE", covariates_list="all", data="all",
                          chopped=FALSE) {
  
  # Input for the program of interest
  df <- df %>%
    filter(!is.na(!!(sym(output_var))),
           !is.na(D),
           !is.na(alt),
           !is.na(black),
           !is.na(caregiver_home),
           m_edu %in% c(1, 2, 3))
  
  if (data=="small") {
    df <- df %>% filter(!is.na(bw))
  }
  
  if (chopped) {
    df <- df %>% filter(black==1, m_edu %in% c(1, 2))
  }
  
  N <- count(df) %>% as.numeric()
  
  # Now create input for ABC and covariates
  if (covariates_list=="all" && data=="all") {
    X <- df %>% select(covariates_all) %>% as.matrix()
    X_abc <- abc %>% select(covariates_all) %>% as.matrix()
  } else if (covariates_list=="all" && data=="small") {
    X <- df %>% select(covariates_small) %>% as.matrix()
    X_abc <- abc %>% select(covariates_small) %>% as.matrix()
  } else if (covariates_list=="short" && data=="all") {
    X <- df %>% select(covariates_short) %>% as.matrix()
    X_abc <- abc %>% select(covariates_short) %>% as.matrix()
  } else if (covariates_list=="short" && data=="small") {
    X <- df %>% select(covariates_short_small) %>% as.matrix()
    X_abc <- abc %>% select(covariates_short_small) %>% as.matrix()
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
    
    if (covariates_list=="all" && data=="all") {
      X <- df_select %>% select(covariates_all) %>% as.matrix()
    } else if (covariates_list=="all" && data=="small") {
      X <- df_select %>% select(covariates_small) %>% as.matrix()
    } else if (covariates_list=="short" && data=="all") {
      X <- df_select %>% select(covariates_short) %>% as.matrix()
    } else if (covariates_list=="short" && data=="small") {
      X <- df_select %>% select(covariates_short_small) %>% as.matrix()
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
    if (data=="all") {
      output <- data.frame(program=program,
                           output_var=output_var,
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
    } else if (data=="small") {
      output <- data.frame(program=program,
                           output_var=output_var,
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
                           bw_importance=var_importance[10],
                           N=N)
    }
  } else if (covariates_list=="short") {
    if (data=="all") {
      output <- data.frame(program=program,
                           output_var=output_var,
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
    } else if (data=="small") {
      output <- data.frame(program=program,
                           output_var=output_var,
                           pre_estimate=output_estimates$t0[1],
                           pre_dr_estimate=output_estimates$t0[2],
                           pre_dr_se=output_estimates$t0[3],
                           pre_dr_p_value=pre_dr_p_value,
                           abc_estimate=output_estimates$t0[4],
                           abc_se=sd(output_estimates$t[,4]),
                           abc_p_value=abc_p_value,
                           m_iq_importance=var_importance[1],
                           m_age_importance=var_importance[2],
                           bw_importance=var_importance[4],
                           N=N)
    }
  }
  return(output)
}


# Execute! ####
# Load data
programs <- c("ehscenter", "ehsmixed_center", "ihdp")

for (p in programs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
                  m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA)))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
         m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA))

ehscenter <- ehscenter %>% mutate(caregiver_home=caregiver_ever)
ehsmixed_center <- ehsmixed_center %>% mutate(caregiver_home=caregiver_ever)

ehscenter_output <- c("ppvt3y")
ehsmixed_center_output <- c("ppvt3y")
ihdp_output <- c("ppvt3y", "sb3y")
abc_output <- c("sb3y")

# Empty data for output
covariates_all_df <- function() {
  df <- data.frame(program=NULL,
                   output_var=NULL,
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

covariates_small_df <- function() {
  df <- data.frame(program=NULL,
                   output_var=NULL,
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
                   bw_importance=NULL,
                   N=NULL)
  return(df)
}

covariates_short_df <- function() {
  df <- data.frame(program=NULL,
                   output_var=NULL,
                   pre_estimate=NULL,
                   pre_dr_estimate=NULL,
                   pre_dr_se=NULL,
                   pre_dr_p_value=NULL,
                   abc_estimate=NULL,
                   abc_se=NULL,
                   abc_p_value=NULL,
                   m_iq_importance=NULL,
                   m_age_importance=NULL,
                   N=NULL)
  return(df)
}

covariates_short_small_df <- function() {
  df <- data.frame(program=NULL,
                   output_var=NULL,
                   pre_estimate=NULL,
                   pre_dr_estimate=NULL,
                   pre_dr_se=NULL,
                   pre_dr_p_value=NULL,
                   abc_estimate=NULL,
                   abc_se=NULL,
                   abc_p_value=NULL,
                   m_iq_importance=NULL,
                   m_age_importance=NULL,
                   bw_importance=NULL,
                   N=NULL)
  return(df)
}

# Output to LaTeX table
output_to_table <- function(df,
                            forest_type="causal",
                            table_type="main",
                            sample="all",
                            covariates_list="all",
                            chopped="") {
  file_name <- paste0(forest_type, "_output_", table_type, "_",
                      sample, "_sample_",
                      covariates_list, "_covariates",
                      chopped, ".tex")
  
  if (table_type=="main") {
    df_select <- df %>%
      select('Program'=program,
             'Outcome'=output_var,
             'Pre-Estimate'=pre_estimate,
             'Pre-DR-Estimate'=pre_dr_estimate,
             'Pre-DR-SE'=pre_dr_se,
             'Pre-DR-p-Value'=pre_dr_p_value,
             'ABC-Estimate'=abc_estimate,
             'ABC-SE'=abc_se,
             'ABC-p-Value'=abc_p_value,
             'N'=N)
    
    digits_vec <- c(rep(0, 3), rep(3, ncol(df_select)-3), 0)
  } else if (table_type=="importance") {
    if (covariates_list=="all") {
      if (sample=="all") {
        df_select <- df %>%
          select('Program'=program,
                 'Outcome'=output_var,
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
        
        digits_vec <- c(rep(0, 3), rep(3, ncol(df_select)-3), 0)
      } else if (sample=="small") {
        df_select <- df %>%
          select('Program'=program,
                 'Outcome'=output_var,
                 'Mother IQ'=m_iq_importance,
                 'Black'=black_importance,
                 'Sex'=sex_importance,
                 'Mother Age'=m_age_importance,
                 'Mother Edu_2'=m_edu_2_importance,
                 'Mother Edu_3'=m_edu_3_importance,
                 'Sibling'=sibling_importance,
                 'Gestational Age'=gestage_importance,
                 'Father'=mf_importance,
                 'Birth Weight'=bw_importance,
                 'N'=N)
        
        digits_vec <- c(rep(0, 3), rep(3, ncol(df_select)-3), 0)
      }
    } else if (covariates_list=="short") {
      if (sample=="all") {
        df_select <- df %>%
          select('Program'=program,
                 'Outcome'=output_var,
                 'Mother IQ'=m_iq_importance,
                 'Mother Age'=m_age_importance,
                 'N'=N)
        
        digits_vec <- c(rep(0, 3), rep(3, ncol(df_select)-3), 0)
      } else if (sample=="small") {
        df_select <- df %>%
          select('Program'=program,
                 'Outcome'=output_var,
                 'Mother IQ'=m_iq_importance,
                 'Mother Age'=m_age_importance,
                 'Birth Weight'=bw_importance,
                 'N'=N)
        
        digits_vec <- c(rep(0, 3), rep(3, ncol(df_select)-3), 0)
      }
    }
  }
  
  print(xtable(df_select, digits=digits_vec, table.placement="H"),
        include.rownames=FALSE,
        comment=FALSE,
        file=paste0(output_dir, file_name))
  
  print(xtable(df_select, digits=digits_vec, table.placement="H"),
        include.rownames=FALSE,
        comment=FALSE,
        file=paste0(output_overleaf, file_name))
}

# Causal forest

causal_output <- covariates_all_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output <- rbind(causal_output,
                           causal_matrix(get(p), v, p))
  }
}

write.csv(causal_output,
          paste0(data_dir, "causal_forest.csv"), row.names=FALSE)

output_to_table(causal_output)
output_to_table(causal_output, table_type="importance")

causal_output_short <- covariates_short_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output_short <-
      rbind(causal_output_short,
            causal_matrix(get(p), v, p,
                          covariates_list="short"))
  }
}

write.csv(causal_output_short,
          paste0(data_dir, "causal_forest_short.csv"), row.names=FALSE)

output_to_table(causal_output_short,
                covariates_list="short")
output_to_table(causal_output_short,
                covariates_list="short", table_type="importance")

causal_output_small <- covariates_all_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output_small <-
      rbind(causal_output_small,
            causal_matrix(get(p), v, p,
                          data="small"))
  }
}

write.csv(causal_output_small,
          paste0(data_dir, "causal_forest_small.csv"), row.names=FALSE)

output_to_table(causal_output_small,
                sample="small")
output_to_table(causal_output_small,
                sample="small", table_type="importance")

causal_output_small_short <- covariates_short_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output_small_short <-
      rbind(causal_output_small_short,
            causal_matrix(get(p), v, p,
                          data="small", covariates_list="short"))
  }
}

write.csv(causal_output_small_short,
          paste0(data_dir, "causal_forest_small_short.csv"), row.names=FALSE)

output_to_table(causal_output_small_short,
                sample="small", covariates_list="short")
output_to_table(causal_output_small_short,
                sample="small", covariates_list="short", table_type="importance")

causal_output_chopped <- covariates_short_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output_chopped <-
      rbind(causal_output_chopped,
            causal_matrix(get(p), v, p,
                          covariates_list="short", chopped=TRUE))
  }
}

write.csv(causal_output_chopped,
          paste0(data_dir, "causal_forest_chopped.csv"), row.names=FALSE)

output_to_table(causal_output_chopped,
                covariates_list="short", chopped="_chopped")
output_to_table(causal_output_chopped,
                covariates_list="short", table_type="importance", chopped="_chopped")

causal_output_small_chopped <- covariates_short_small_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output_small_chopped <-
      rbind(causal_output_small_chopped,
            causal_matrix(get(p), v, p,
                          data="small", covariates_list="short", chopped=TRUE))
  }
}

write.csv(causal_output_small_chopped,
          paste0(data_dir, "causal_forest_small_chopped.csv"), row.names=FALSE)

output_to_table(causal_output_small_chopped,
                sample="small", covariates_list="short", chopped="_chopped")
output_to_table(causal_output_small_chopped,
                sample="small", covariates_list="short", table_type="importance", chopped="_chopped")

# Instrumental forest

instrumental_output <- covariates_all_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output <-
      rbind(instrumental_output,
            causal_matrix(get(p), v, p,
                          method="LATE"))
  }
}

write.csv(instrumental_output,
          paste0(data_dir, "instrumental_forest.csv"), row.names=FALSE)

output_to_table(instrumental_output)
output_to_table(instrumental_output,
                table_type="importance")

instrumental_output_short <- covariates_short_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output_short <-
      rbind(instrumental_output_short,
            causal_matrix(get(p), v, p,
                          method="LATE", covariates_list="short"))
  }
}

write.csv(instrumental_output_short,
          paste0(data_dir, "instrumental_forest_short.csv"), row.names=FALSE)

output_to_table(instrumental_output_short,
                covariates_list="short")
output_to_table(instrumental_output_short,
                covariates_list="short", table_type="importance")

instrumental_output_small <- covariates_all_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output_small <-
      rbind(instrumental_output_small,
            causal_matrix(get(p), v, p,
                          method="LATE", data="small"))
  }
}

write.csv(instrumental_output_small,
          paste0(data_dir, "instrumental_forest_small.csv"), row.names=FALSE)

output_to_table(instrumental_output_small,
                sample="small")
output_to_table(instrumental_output_small,
                sample="small", table_type="importance")

instrumental_output_small_short <- covariates_short_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output_small_short <-
      rbind(instrumental_output_small_short,
            causal_matrix(get(p), v, p,
                          method="LATE", data="small", covariates_list="short"))
  }
}

write.csv(instrumental_output_small_short,
          paste0(data_dir, "instrumental_forest_small_short.csv"), row.names=FALSE)

output_to_table(instrumental_output_small_short,
                sample="small", covariates_list="short")
output_to_table(instrumental_output_small_short,
                sample="small", covariates_list="short", table_type="importance")

instrumental_output_chopped <- covariates_short_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output_chopped <-
      rbind(instrumental_output_chopped,
            causal_matrix(get(p), v, p,
                          method="LATE", covariates_list="short", chopped=TRUE))
  }
}

write.csv(instrumental_output_chopped,
          paste0(data_dir, "instrumental_forest_chopped.csv"), row.names=FALSE)

output_to_table(instrumental_output_chopped,
                covariates_list="short", chopped="_chopped")
output_to_table(instrumental_output_chopped,
                covariates_list="short", table_type="importance", chopped="_chopped")

instrumental_output_small_chopped <- covariates_short_small_df()

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output_small_chopped <-
      rbind(instrumental_output_small_chopped,
            causal_matrix(get(p), v, p,
                          method="LATE", data="small", covariates_list="short", chopped=TRUE))
  }
}

write.csv(instrumental_output_small_chopped,
          paste0(data_dir, "instrumental_forest_small_chopped.csv"), row.names=FALSE)

output_to_table(instrumental_output_small_chopped,
                sample="small", covariates_list="short", chopped="_chopped")
output_to_table(instrumental_output_small_chopped,
                sample="small", covariates_list="short", table_type="importance", chopped="_chopped")

end_time <- Sys.time()
end_time-start_time
