start_time <- Sys.time()

# Estimates for the main tables.
# Every specification is labelled by
#   program:       "ehs-full", "ehsmixed_center", "ehscenter", "abc"
#   participation: "any" (E/P), "1m", "6m", "12m", "18m" (D_m/P_m)
#   subsample:     FALSE (full sample) or TRUE (black children, mothers without college)
#   method:        "ITT" (treatment assignment R) or "LATE" (participation D instrumented by R)
#   covariates:    "none", "all", or "short" (mother's IQ and age only)
# and every output file is a long data frame with one row per specification,
# so the table scripts can pick estimates by name instead of by row/column number.

covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf", "poverty")
covariates_subsample_all <- c("m_iq", "sex", "m_age",
                              "sibling", "gestage", "mf", "poverty")
covariates_short <- c("m_iq", "m_age")

# Bootstrap for the forests predicted on ABC: replications run in parallel on a
# cluster of NCPUS workers (from preliminary.R), each fitting one single-threaded
# forest at a time. Resampling is seeded, and every forest and FRA fit is seeded
# below, so rerunning this script reproduces its numbers.
bootstrap_replications <- 1000
bootstrap_cluster <- parallel::makeCluster(NCPUS)
parallel::clusterEvalQ(bootstrap_cluster, {
  library(grf)
  library(dplyr)
})
parallel::clusterExport(bootstrap_cluster, "seed")
parallel::clusterSetRNGStream(bootstrap_cluster, seed)

# Covariate list for a covariate label
# In the subsample, race and mother's education do not vary, so "all" drops them
select_covariates <- function(covariates, subsample=FALSE) {
  switch(covariates,
         none=NULL,
         short=covariates_short,
         all=if (subsample) covariates_subsample_all else covariates_all)
}

# Label columns attached to every output
specification_labels <- function(program, subsample, method, covariates) {
  data.frame(program=program,
             subsample=subsample,
             method=method,
             covariates=covariates)
}


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
           m_edu %in% c(1, 2, 3),
           !is.na(poverty))

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

# Forest estimates (causal forest for ITT, instrumental forest for LATE)
# forest_ate_*: doubly-robust average treatment effect on the program of interest
# forest_abc_*: forest fit on the program of interest, predicted on ABC covariates
#               (standard error and p-value from the bootstrap)
forest_matrix <- function(df_from, df_to, program,
                          method="ITT",
                          covariates="all",
                          subsample=FALSE) {
  covariates_list <- select_covariates(covariates, subsample)

  df_from <- clean_data(df_from, subsample)
  N <- count(df_from) %>% as.numeric()
  X_from <- covariate_selection(df_from, covariates_list)
  W <- df_from$R
  Y <- df_from$iq
  Z <- df_from$D
  X_to <- covariate_selection(df_to, covariates_list)

  # Fit the causal/instrumental forest on the program of interest
  if (method=="ITT") {
    forest <- causal_forest(X_from, Y, W, seed=seed)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X_from, Y, W, Z, seed=seed)
  }

  forest_prediction_mean <- mean(forest$predictions)
  forest_ate_estimate <- average_treatment_effect(forest)[[1]]
  forest_ate_se <- average_treatment_effect(forest)[[2]]

  # Run bootstrap
  forest_boot <- function(data, index) {
    df_select <- data[index,]

    X_select <- df_select %>% select(all_of(covariates_list)) %>% as.matrix()
    W_select <- df_select$R
    Y_select <- df_select$iq
    Z_select <- df_select$D

    # Fit the causal/instrumental forest on the program of interest
    # (one thread per worker; grf results do not depend on the thread count)
    if (method=="ITT") {
      forest <- causal_forest(X_select, Y_select, W_select, seed=seed, num.threads=1)
    } else if (method=="LATE") {
      forest <- instrumental_forest(X_select, Y_select, W_select, Z_select, seed=seed,
                                    num.threads=1)
    }

    to_estimate <- mean(predict(forest, X_to)$predictions)
    return(to_estimate)
  }

  # Resampling indices are drawn here, so the seed makes the bootstrap reproducible
  set.seed(seed)
  output_estimates <- boot(data=df_from,
                           statistic=forest_boot,
                           R=bootstrap_replications,
                           parallel="snow", ncpus=NCPUS, cl=bootstrap_cluster)

  forest_ate_p_value <- 2*pnorm(-forest_ate_estimate/forest_ate_se)
  forest_abc_p_value <- boot.pval(output_estimates)

  output <- cbind(specification_labels(program, subsample, method, covariates),
                  data.frame(N=N,
                             forest_prediction_mean=forest_prediction_mean,
                             forest_ate_estimate=forest_ate_estimate,
                             forest_ate_se=forest_ate_se,
                             forest_ate_p_value=forest_ate_p_value,
                             forest_abc_estimate=output_estimates$t0,
                             forest_abc_se=sd(output_estimates$t),
                             forest_abc_p_value=forest_abc_p_value))
  return(output)
}

# Variable importance can be run outside bootstrap
variable_importance_matrix <- function(df, program,
                                       covariates="all", subsample=FALSE,
                                       method="ITT") {
  covariates_list <- select_covariates(covariates, subsample)

  df <- clean_data(df, subsample)
  X <- covariate_selection(df, covariates_list)
  W <- df$R
  Y <- df$iq
  Z <- df$D

  # Fit the causal/instrumental forest on the program of interest
  if (method=="ITT") {
    forest <- causal_forest(X, Y, W, seed=seed)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X, Y, W, Z, seed=seed)
  }

  var_importance <- variable_importance(forest)
  result <- left_join(data.frame(covariate=covariates_all),
                      data.frame(covariate=covariates_list,
                                 var_importance=var_importance),
                      by="covariate")
  result <- cbind(result,
                  specification_labels(program, subsample, method, covariates))
  return(result)
}

# Basic regression (OLS for ITT, 2SLS for LATE), one row per estimated variable
# The treatment effect is the coefficient on R (ITT) or on D (LATE)
regression_matrix <- function(df, program,
                              method="ITT",
                              covariates="all",
                              subsample=FALSE) {
  covariates_list <- select_covariates(covariates, subsample)

  df_select <- clean_data(df, subsample)

  # Fit the (IV) regression on the program of interest
  if (method=="ITT") {
    fit <- lm(as.formula(paste(c("iq~R", covariates_list), collapse="+")),
              data=df_select)
    variables <- c("Constant", "R", covariates_list)
    F_stat <- NA
  } else if (method=="LATE") {
    fit <- ivreg(as.formula(paste0(paste(c("iq~D", covariates_list), collapse="+"),
                                   "|",
                                   paste(c("R", covariates_list), collapse="+"))),
                 data=df_select)
    variables <- c("Constant", "D", covariates_list)
    F_stat <- summary(fit)$diagnostic[1, 3] %>% as.numeric()
  }

  output <- cbind(specification_labels(program, subsample, method, covariates),
                  data.frame(variable=variables,
                             coefficient=summary(fit)$coefficients[, 1] %>% as.numeric(),
                             se=summary(fit)$coefficients[, 2] %>% as.numeric(),
                             p_value=summary(fit)$coefficients[, 4] %>% as.numeric(),
                             F_stat=F_stat,
                             N=nobs(fit)))
  return(output)
}

# FRA estimates (flexible regression adjustment)
fra_matrix <- function(df, program,
                       method="ITT",
                       covariates="all",
                       subsample=FALSE) {
  covariates_list <- select_covariates(covariates, subsample)

  df_select <- clean_data(df, subsample)

  # FRA shuffles the sample into cross-fitting folds and (for LATE) fits random forests
  set.seed(seed)

  # Fit the (IV) regression on the program of interest
  if (method=="ITT") {
    fra_df <- FRA(df_select, outcome_cols="iq",
                  treat_col="R", method="linear",
                  covariate_cols=covariates_list)

    fra_ate <- FRA_ATE(fra_df, outcome_col='iq', 1, 0)
    z_value <- fra_ate[1]/fra_ate[2]
    p_value_z <- 2*(1-pnorm(abs(z_value)))

    output <- data.frame(estimate=fra_ate[1],
                         se=fra_ate[2],
                         p_value=p_value_z)

  } else if (method=="LATE") {
    fra_df <- FRA(df_select, outcome_cols="iq",
                  treat_col="R", method="rf",
                  covariate_cols=covariates_list)

    fra_denom <- FRA(df_select, outcome_cols="D",
                     treat_col="R", method="rf",
                     covariate_cols=covariates_list)

    fra_df <- fra_df %>%
      left_join(fra_denom %>% select(id, u_D_0, u_D_1), by="id")

    fra_late <- FRA_LATE(fra_df, outcome_col='iq', endog_col='D', 1, 0)
    z_value <- fra_late[1]/fra_late[2]
    p_value_z <- 2*(1-pnorm(abs(z_value)))

    output <- data.frame(estimate=fra_late[1],
                         se=fra_late[2],
                         p_value=p_value_z)
  }

  output <- cbind(specification_labels(program, subsample, method, covariates),
                  output)
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
           subsample=subsample,
           N=N) %>%
    select(program, subsample, N, p_nh, p_ch, nh_share, p_hh, p_cc, p_nn)
  return(stats)
}


# Specifications to estimate ####
# Forests: full sample with all/short covariates, subsample with short covariates
forest_specifications <- expand_grid(method=c("ITT", "LATE"),
                                     tribble(~subsample, ~covariates,
                                             FALSE,      "all",
                                             FALSE,      "short",
                                             TRUE,       "short"))

regression_specifications <- expand_grid(subsample=c(FALSE, TRUE),
                                         method=c("ITT", "LATE"),
                                         covariates=c("none", "all", "short"))

fra_specifications <- expand_grid(subsample=c(FALSE, TRUE),
                                  method=c("ITT", "LATE"),
                                  covariates=c("all", "short"))


# Execute! ####
# Load data and estimate everything for one definition of participation
participation_run <- function(participation, D_var, alt_var) {
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
    D_values <- df %>% select(all_of(D_var_int)) %>% unlist() %>% as.numeric()
    alt_values <- df %>% select(all_of(alt_var_int)) %>% unlist() %>% as.numeric()
    df$D <- D_values
    df$alt <- alt_values
    return(df)
  }

  for (p in programs) {
    assign(p, define_participation(get(p), D_var, alt_var))
  }

  # Build all output
  forest_output <- data.frame()
  regression_output <- data.frame()
  fra_output <- data.frame()
  prevalence_output <- data.frame()

  for (p in programs) {
    start_time_p <- Sys.time()

    for (s in seq_len(nrow(forest_specifications))) {
      forest_output <-
        bind_rows(forest_output,
                  forest_matrix(get(p), abc, p,
                                method=forest_specifications$method[s],
                                covariates=forest_specifications$covariates[s],
                                subsample=forest_specifications$subsample[s]))
    }

    end_time_p <- Sys.time()
    print(paste0("Program ", p, ": ", end_time_p-start_time_p))
  }

  for (p in programs) {
    for (s in seq_len(nrow(regression_specifications))) {
      regression_output <-
        bind_rows(regression_output,
                  regression_matrix(get(p), p,
                                    method=regression_specifications$method[s],
                                    covariates=regression_specifications$covariates[s],
                                    subsample=regression_specifications$subsample[s]))
    }
  }

  for (p in programs) {
    for (s in seq_len(nrow(fra_specifications))) {
      fra_output <-
        bind_rows(fra_output,
                  fra_matrix(get(p), p,
                             method=fra_specifications$method[s],
                             covariates=fra_specifications$covariates[s],
                             subsample=fra_specifications$subsample[s]))
    }
  }

  for (p in programs) {
    prevalence_output <- bind_rows(prevalence_output,
                                   type_prevalence(get(p), p, subsample=FALSE))
    prevalence_output <- bind_rows(prevalence_output,
                                   type_prevalence(get(p), p, subsample=TRUE))
  }

  # Save
  save_output <- function(output, name) {
    write.csv(output %>% add_column(participation=participation, .before=1),
              file=paste0(output_git, name, "_", participation, ".csv"),
              row.names=FALSE)
  }

  save_output(forest_output, "forest_output")
  save_output(regression_output, "regression_output")
  save_output(fra_output, "fra_output")
  save_output(prevalence_output, "prevalence_output")
}

participation_run(participation="any", D_var="D", alt_var="P")
participation_run(participation="1m", D_var="D_1", alt_var="P_1")
participation_run(participation="6m", D_var="D_6", alt_var="P_6")
participation_run(participation="12m", D_var="D_12", alt_var="P_12")
participation_run(participation="18m", D_var="D_18", alt_var="P_18")

parallel::stopCluster(bootstrap_cluster)

end_time <- Sys.time()
end_time-start_time
