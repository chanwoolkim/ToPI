start_time <- Sys.time()

covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf")
covariates_subsample_all <- c("m_iq", "sex", "m_age",
                              "sibling", "gestage", "mf")
covariates_short <- c("m_iq", "m_age")


# Function to create data frame for output estimates ####
# Input for the program of interest
clean_data <- function(df, subsample) {
  df_output <- df %>%
    filter(!is.na(iq),
           !is.na(R),
           !is.na(E),
           !is.na(D), 
           !is.na(alt),
           !is.na(m_iq),
           !is.na(black),
           !is.na(sex),
           !is.na(m_age),
           !is.na(sibling),
           !is.na(gestage),
           !is.na(mf),
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
                          method="ITT", 
                          covariates_list=covariates_all, 
                          subsample=FALSE,
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
    
    fit <- lm(iq~R, data=df_from)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X_from, Y, W, Z,
                                  honesty=honesty, min.node.size=min.node.size, seed=seed)
    
    fit <- ivreg(iq~D|R, data=df_from)
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
                              method="ITT", 
                              covariates=TRUE, covariates_list=covariates_all, 
                              subsample=FALSE) {
  df_select <- clean_data(df, subsample)
  
  # Fit the (IV) regression on the program of interest
  if (method=="ITT") {
    if (covariates) {
      fit <- lm(as.formula(paste0("iq~R+",
                                  paste(covariates_list, collapse="+"))),
                data=df_select)
      output <- data.frame(variable=c("Constant", "R", covariates_list),
                           coefficient=summary(fit)$coefficients[, 1] %>% as.numeric(),
                           se=summary(fit)$coefficients[, 2] %>% as.numeric(),
                           p_value=summary(fit)$coefficients[, 4] %>% as.numeric(),
                           F_stat=NA,
                           N=nobs(fit))
    } else {
      fit <- lm(iq~R, data=df_select)
      output <- data.frame(variable=c("Constant", "R"),
                           coefficient=summary(fit)$coefficients[, 1] %>% as.numeric(),
                           se=summary(fit)$coefficients[, 2] %>% as.numeric(),
                           p_value=summary(fit)$coefficients[, 4] %>% as.numeric(),
                           F_stat=NA,
                           N=nobs(fit))
    }
    
  } else if (method=="LATE") {
    if (covariates) {
      fit <- ivreg(as.formula(paste0("iq~D+",
                                     paste(covariates_list, collapse="+"),
                                     "|R+",
                                     paste(covariates_list, collapse="+"))),
                   data=df_select)
      output <- data.frame(variable=c("Constant", "D", covariates_list),
                           coefficient=summary(fit)$coefficients[, 1] %>% as.numeric(),
                           se=summary(fit)$coefficients[, 2] %>% as.numeric(),
                           p_value=summary(fit)$coefficients[, 4] %>% as.numeric(),
                           F_stat=summary(fit)$diagnostic[1, 3] %>% as.numeric(),
                           N=nobs(fit))
    } else {
      fit <- ivreg(iq~D|R, data=df_select)
      output <- data.frame(variable=c("Constant", "D"),
                           coefficient=summary(fit)$coefficients[, 1] %>% as.numeric(),
                           se=summary(fit)$coefficients[, 2] %>% as.numeric(),
                           p_value=summary(fit)$coefficients[, 4] %>% as.numeric(),
                           F_stat=summary(fit)$diagnostic[1, 3] %>% as.numeric(),
                           N=nobs(fit))
    }
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
participation_run <- function(D_var, alt_var) {
  programs_ehs <- c("ehs-full", "ehsmixed_center", "ehscenter")
  programs <- c(programs_ehs, "abc")
  
  for (p in programs_ehs) {
    assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
             mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
                    m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA)) %>%
             rename(iq=ppvt3y))
  }
  
  abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
    mutate(E=D,
           m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
           m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA),
           caregiver_home=1) %>%
    rename(iq=sb3y)
  
  `ehs-full` <- `ehs-full` %>%
    mutate(caregiver_home=caregiver_ever,
           H=ifelse(D==1, 4140/6000, ifelse(D==0, 0, NA)))
  
  ehscenter <- ehscenter %>%
    mutate(caregiver_home=caregiver_ever,
           H=ifelse(D==1, 4140/6000, ifelse(D==0, 0, NA)))
  
  ehsmixed_center <- ehsmixed_center %>%
    mutate(caregiver_home=caregiver_ever,
           H=ifelse(D==1, 4140/6000, ifelse(D==0, 0, NA)))
  
  define_participation <- function(df, D_var_int, alt_var_int) {
    D_values <- df %>% select(D_var_int) %>% unlist() %>% as.numeric()
    alt_values <- df %>% select(alt_var_int) %>% unlist() %>% as.numeric()
    df$D <- D_values
    df$alt <- alt_values
    return(df)
  }
  
  for (p in programs) {
    assign(p, define_participation(get(p), D_var, alt_var))
  }
  
  # Build all output
  # Base case
  causal_output <- data.frame()
  instrumental_output <- data.frame()
  variable_importance_output <- data.frame()
  regression_output <- data.frame(variable=c("R", "D", covariates_all, "Constant"))
  prevalence_output <- data.frame()
  
  for (p in programs) {
    start_time_p <- Sys.time()
    
    causal_output <- bind_rows(causal_output,
                               causal_matrix(get(p), abc, p, "abc"))
    instrumental_output <- bind_rows(instrumental_output,
                                     causal_matrix(get(p), abc, p, "abc", method="LATE"))
    
    causal_output <-
      bind_rows(causal_output,
                causal_matrix(get(p), abc, p, "abc",
                              covariates_list=covariates_short))
    instrumental_output <-
      bind_rows(instrumental_output,
                causal_matrix(get(p), abc, p, "abc",
                              covariates_list=covariates_short,
                              method="LATE"))
    
    causal_output <-
      bind_rows(causal_output,
                causal_matrix(get(p), abc, p, "abc",
                              covariates_list=covariates_short, subsample=TRUE))
    instrumental_output <-
      bind_rows(instrumental_output,
                causal_matrix(get(p), abc, p, "abc",
                              covariates_list=covariates_short, subsample=TRUE,
                              method="LATE"))
    
    end_time_p <- Sys.time()
    print(paste0("Program ", p, ": ", end_time_p-start_time_p))
  }
  
  for (p in programs) {
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p, 
                                                     covariates=FALSE),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates_list=covariates_short),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p, 
                                                     covariates=FALSE,
                                                     method="LATE"),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p, method="LATE"),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates_list=covariates_short,
                                                     method="LATE"),
                                   by="variable")
    
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates=FALSE, 
                                                     subsample=TRUE),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates_list=covariates_subsample_all,
                                                     subsample=TRUE),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates_list=covariates_short,
                                                     subsample=TRUE),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates=FALSE,
                                                     subsample=TRUE, method="LATE"),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates_list=covariates_subsample_all,
                                                     subsample=TRUE, method="LATE"),
                                   by="variable")
    regression_output <- left_join(regression_output,
                                   regression_matrix(get(p), p,
                                                     covariates_list=covariates_short,
                                                     subsample=TRUE, method="LATE"),
                                   by="variable")
    
    prevalence_output <- bind_rows(prevalence_output,
                                   type_prevalence(get(p), p, subsample=FALSE))
    prevalence_output <- bind_rows(prevalence_output,
                                   type_prevalence(get(p), p, subsample=TRUE))
  }
  
  # Save
  write.csv(causal_output,
            file=paste0(output_git, "causal_output", 
                        "_", D_var, "_", alt_var, ".csv"),
            row.names=FALSE)
  write.csv(instrumental_output,
            file=paste0(output_git, "instrumental_output", 
                        "_", D_var, "_", alt_var, ".csv"),
            row.names=FALSE)
  write.csv(regression_output,
            file=paste0(output_git, "regression_output", 
                        "_", D_var, "_", alt_var, ".csv"),
            row.names=FALSE)
  write.csv(prevalence_output,
            file=paste0(output_git, "prevalence_output", 
                        "_", D_var, "_", alt_var, ".csv"),
            row.names=FALSE)
}

participation_run(D_var="E", alt_var="P")
participation_run(D_var="D", alt_var="P")
participation_run(D_var="D_1", alt_var="P_1")
participation_run(D_var="D_6", alt_var="P_6")
participation_run(D_var="D_12", alt_var="P_12")
participation_run(D_var="D_18", alt_var="P_18")

end_time <- Sys.time()
end_time-start_time
