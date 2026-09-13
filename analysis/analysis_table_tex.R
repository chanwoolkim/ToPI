start_time <- Sys.time()

# Load estimates ####
# One file per participation definition ("any", "1m", "6m", "12m", "18m");
# each file already carries a participation column, so they stack into one data frame
participation_definitions <- c("any", "1m", "6m", "12m", "18m")

load_output <- function(name) {
  bind_rows(lapply(participation_definitions, function(participation) {
    read.csv(paste0(output_git, name, "_", participation, ".csv"))
  }))
}

forest_output <- load_output("forest_output")
regression_output <- load_output("regression_output")
fra_output <- load_output("fra_output")
prevalence_output <- load_output("prevalence_output")


# Lookups ####
# Each returns one row with estimate, se, p_value (and N) for one specification:
#   program:       "ehs-full", "ehsmixed_center", "ehscenter", "abc"
#   participation: "any", "1m", "6m", "12m", "18m"
#   subsample:     FALSE (full) or TRUE (black children, mothers without college)
#   method:        "ITT" or "LATE"
#   covariates:    "none", "all", "short" (mother's IQ and age)

# Regression: coefficient on R (ITT, OLS) or D (LATE, 2SLS)
regression_estimate <- function(program, participation, subsample, method, covariates) {
  regression_output %>%
    filter(program==.env$program,
           participation==.env$participation,
           subsample==.env$subsample,
           method==.env$method,
           covariates==.env$covariates,
           variable==ifelse(method=="ITT", "R", "D")) %>%
    transmute(estimate=coefficient, se, p_value, N)
}

# Flexible regression adjustment
fra_estimate <- function(program, participation, subsample, method, covariates) {
  fra_output %>%
    filter(program==.env$program,
           participation==.env$participation,
           subsample==.env$subsample,
           method==.env$method,
           covariates==.env$covariates) %>%
    transmute(estimate, se, p_value)
}

# Forest (causal forest for ITT, instrumental forest for LATE):
# doubly-robust ATE on the program itself, or the forest predicted on ABC covariates
forest_estimate <- function(program, participation, subsample, method, covariates,
                            predicted_on_abc=FALSE) {
  forest_row <- forest_output %>%
    filter(program==.env$program,
           participation==.env$participation,
           subsample==.env$subsample,
           method==.env$method,
           covariates==.env$covariates)
  if (predicted_on_abc) {
    forest_row %>% transmute(estimate=forest_abc_estimate, se=forest_abc_se, p_value=forest_abc_p_value, N)
  } else {
    forest_row %>% transmute(estimate=forest_ate_estimate, se=forest_ate_se, p_value=forest_ate_p_value, N)
  }
}

# Same lookup for every column of a table: `columns` has one row per table column
# (program, participation); the remaining arguments are shared by all columns
estimates_by_column <- function(columns, estimate_function, ...) {
  bind_rows(pmap(columns, estimate_function, ...))
}

# Two rows of a table: estimates with significance stars, then standard errors
# in parentheses; `dash` adds "-" for a column without an estimate
estimate_rows <- function(label, estimates, cspan=rep(1, nrow(estimates)), dash=FALSE) {
  estimate_row <- TexRow(label) /
    TexRow(estimates$estimate, pvalues=estimates$p_value, cspan=cspan, dec=2)
  if (dash) {
    estimate_row <- estimate_row / TexRow("-")
  }
  se_row <- TexRow("") /
    TexRow(estimates$se, cspan=cspan, dec=2, se=TRUE)
  return(estimate_row+se_row)
}


# Output to LaTeX tables ####
# Summary of important coefficients: ITT and LATE by program type
coefficients_tex <- function() {
  # ITT columns: All, Center + Mixed, Center Only (spanning three columns), ABC
  itt_columns <- tribble(~program,          ~participation,
                         "ehs-full",        "any",
                         "ehsmixed_center", "any",
                         "ehscenter",       "any",
                         "abc",             "12m")
  itt_cspan <- c(1, 1, 3, 1)
  itt_columns_ehs <- itt_columns %>% filter(program!="abc")
  itt_cspan_ehs <- c(1, 1, 3)

  # LATE columns: All, Center + Mixed, Center Only by participation (any, 6m, 12m), ABC
  late_columns <- tribble(~program,          ~participation,
                          "ehs-full",        "any",
                          "ehsmixed_center", "any",
                          "ehscenter",       "any",
                          "ehscenter",       "6m",
                          "ehscenter",       "12m",
                          "abc",             "12m")
  late_columns_ehs <- late_columns %>% filter(program!="abc")

  # Sample sizes (identical across participation definitions)
  sample_size <- function(subsample) {
    estimates_by_column(itt_columns, regression_estimate,
                        subsample=subsample, method="ITT", covariates="all") %>%
      pull(N)
  }

  tab <- TexRow(c("", "ITT"), cspan=c(1, 6)) +
    TexMidrule(list(c(2, 7))) +
    TexRow(c("Program ", "EHS", "ABC"), cspan=c(1, 5, 1)) +
    TexMidrule(list(c(2, 6), c(7, 7))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 1, 3, 1)) +
    TexMidrule() +
    estimate_rows("Full",
                  estimates_by_column(itt_columns, regression_estimate,
                                      subsample=FALSE, method="ITT", covariates="all"),
                  cspan=itt_cspan) +
    estimate_rows("Full/FRA",
                  estimates_by_column(itt_columns, fra_estimate,
                                      subsample=FALSE, method="ITT", covariates="all"),
                  cspan=itt_cspan) +
    estimate_rows("Subsample",
                  estimates_by_column(itt_columns, regression_estimate,
                                      subsample=TRUE, method="ITT", covariates="all"),
                  cspan=itt_cspan) +
    estimate_rows("Subsample/FRA",
                  estimates_by_column(itt_columns, fra_estimate,
                                      subsample=TRUE, method="ITT", covariates="all"),
                  cspan=itt_cspan) +
    estimate_rows("Subsample/Causal Forest",
                  estimates_by_column(itt_columns, forest_estimate,
                                      subsample=TRUE, method="ITT", covariates="short"),
                  cspan=itt_cspan) +
    estimate_rows("Subsample/Causal Forest (ABC)",
                  estimates_by_column(itt_columns_ehs, forest_estimate,
                                      subsample=TRUE, method="ITT", covariates="short",
                                      predicted_on_abc=TRUE),
                  cspan=itt_cspan_ehs, dash=TRUE) +
    TexMidrule() +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(1, 6)) +
    TexMidrule(list(c(2, 7))) +
    TexRow(c("Program ", "EHS", "ABC"), cspan=c(1, 5, 1)) +
    TexMidrule(list(c(2, 6), c(7, 7))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 1, 3, 1)) +
    TexMidrule(list(c(2, 2), c(3, 3), c(4, 6), c(7, 7))) +
    TexRow(c("Participation", "Any", "Any", "Any", "6m", "12m", "12m")) +
    TexMidrule() +
    estimate_rows("Full",
                  estimates_by_column(late_columns, regression_estimate,
                                      subsample=FALSE, method="LATE", covariates="all")) +
    estimate_rows("Full/FRA",
                  estimates_by_column(late_columns, fra_estimate,
                                      subsample=FALSE, method="LATE", covariates="all")) +
    estimate_rows("Subsample",
                  estimates_by_column(late_columns, regression_estimate,
                                      subsample=TRUE, method="LATE", covariates="all")) +
    estimate_rows("Subsample/FRA",
                  estimates_by_column(late_columns, fra_estimate,
                                      subsample=TRUE, method="LATE", covariates="all")) +
    estimate_rows("Subsample/Instrumental Forest",
                  estimates_by_column(late_columns, forest_estimate,
                                      subsample=TRUE, method="LATE", covariates="short")) +
    estimate_rows("Subsample/Instrumental Forest (ABC)",
                  estimates_by_column(late_columns_ehs, forest_estimate,
                                      subsample=TRUE, method="LATE", covariates="short",
                                      predicted_on_abc=TRUE),
                  dash=TRUE) +
    TexMidrule() +
    TexMidrule() +
    TexRow("Sample Size: Full") /
    TexRow(sample_size(subsample=FALSE), cspan=itt_cspan, dec=0) +
    TexRow("Sample Size: Subsample") /
    TexRow(sample_size(subsample=TRUE), cspan=itt_cspan, dec=0)
  return(tab)
}

tab <- coefficients_tex()
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 6)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 6)),
        output_path=output_git, stand_alone=FALSE)

# Progress table: EHS estimate next to the ABC estimate, one row per specification
progress_tex <- function() {
  # Two rows: (coefficient, N) for EHS and, if given, for ABC; then the standard errors
  # `labels` are the Type, Sample, and Participation columns
  progress_rows <- function(labels, ehs, abc=NULL, se_labels=rep("", 3)) {
    if (is.null(abc)) {
      estimate_row <- TexRow(labels) /
        TexRow(c(ehs$estimate, ehs$N), pvalues=c(ehs$p_value, 1), dec=c(2, 0)) /
        TexRow("-")
      se_row <- TexRow(se_labels) /
        TexRow(c(ehs$se, NA), dec=2, se=TRUE)
    } else {
      estimate_row <- TexRow(labels) /
        TexRow(c(ehs$estimate, ehs$N, abc$estimate, abc$N),
               pvalues=c(ehs$p_value, 1, abc$p_value, 1), dec=rep(c(2, 0), 2))
      se_row <- TexRow(se_labels) /
        TexRow(c(ehs$se, NA, abc$se, NA), dec=rep(c(2, 0), 2), se=TRUE)
    }
    return(estimate_row+se_row)
  }

  tab <- TexRow(c("Program", "EHS", "ABC"),
                cspan=c(3, 2, 2), position=c("l", "c", "c")) +
    TexMidrule(list(c(1, 3), c(4, 5), c(6, 7))) +
    TexRow(c("Type", "Sample", "Participation", rep(c("Coefficient", "Obs"), 2))) +
    TexMidrule() +
    TexRow(c("", "ITT"), cspan=c(3, 4)) +
    TexMidrule(list(c(4, 7))) +
    progress_rows(c("All", "Full", "Any"),
                  ehs=regression_estimate("ehs-full", "any", subsample=FALSE, "ITT", "all")) +
    progress_rows(c("Center $+$ Mixed", "Full", "Any"),
                  ehs=regression_estimate("ehsmixed_center", "any", subsample=FALSE, "ITT", "all")) +
    progress_rows(c("Center Only", "Full", "Any"),
                  ehs=regression_estimate("ehscenter", "any", subsample=FALSE, "ITT", "all"),
                  abc=regression_estimate("abc", "any", subsample=FALSE, "ITT", "all")) +
    progress_rows(c("Center Only", "Subsample", "Any"),
                  ehs=regression_estimate("ehscenter", "any", subsample=TRUE, "ITT", "all"),
                  abc=regression_estimate("abc", "any", subsample=TRUE, "ITT", "all")) +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(3, 4)) +
    TexMidrule(list(c(4, 7))) +
    progress_rows(c("Center Only", "Subsample", "Any"),
                  ehs=regression_estimate("ehscenter", "any", subsample=TRUE, "LATE", "all"),
                  abc=regression_estimate("abc", "any", subsample=TRUE, "LATE", "all")) +
    progress_rows(c("Center Only", "Subsample", "6m"),
                  ehs=regression_estimate("ehscenter", "6m", subsample=TRUE, "LATE", "all"),
                  abc=regression_estimate("abc", "6m", subsample=TRUE, "LATE", "all")) +
    progress_rows(c("Center Only", "Subsample", "12m"),
                  ehs=regression_estimate("ehscenter", "12m", subsample=TRUE, "LATE", "all"),
                  abc=regression_estimate("abc", "12m", subsample=TRUE, "LATE", "all")) +
    progress_rows(c("Center Only", "Subsample", "12m"),
                  ehs=forest_estimate("ehscenter", "12m", subsample=TRUE, "LATE", "short",
                                      predicted_on_abc=TRUE),
                  se_labels=c("", "(Instrumental Forest (ABC))", ""))
  return(tab)
}

tab <- progress_tex()
TexSave(tab, filename="progress_base", positions=c(rep('l', 3), rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="progress_base", positions=c(rep('l', 3), rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

# Prevalence of compliance types and subLATE bounds (subsample, 12-month participation)
prevalence_sublate_tex <- function() {
  prevalence_ehscenter <- prevalence_output %>%
    filter(program=="ehscenter", participation=="12m", subsample==TRUE)
  prevalence_abc <- prevalence_output %>%
    filter(program=="abc", participation=="12m", subsample==TRUE)

  # LATE without covariates
  late_ehscenter <- regression_estimate("ehscenter", "12m", subsample=TRUE, "LATE", "none")$estimate
  late_abc <- regression_estimate("abc", "12m", subsample=TRUE, "LATE", "none")$estimate

  # One prevalence statistic for EHS Center Only and ABC, each spanning two columns
  prevalence_row <- function(label, statistic, dec=2) {
    TexRow(label) /
      TexRow(c(prevalence_ehscenter[[statistic]], prevalence_abc[[statistic]]),
             cspan=c(2, 2), dec=dec)
  }

  tab <- TexRow(c("Program", "EHS Center Only", "ABC"), cspan=c(1, 2, 2)) +
    TexMidrule() +
    TexRow(c("", "Prevalence of Compliance Types"), cspan=c(1, 4)) +
    TexMidrule(list(c(2, 5))) +
    prevalence_row("\\textbf{Observations}", "N", dec=0) +
    TexRow("\\textbf{Compliers}") +
    prevalence_row("\\quad $p_{nh}$", "p_nh") +
    prevalence_row("\\quad $p_{ch}$", "p_ch") +
    TexRow("\\textbf{Share}") +
    prevalence_row("\\quad $\\omega_{nh}$", "nh_share") +
    TexRow("\\textbf{Always-Takers}") +
    prevalence_row("\\quad $p_{hh}$", "p_hh") +
    prevalence_row("\\quad $p_{cc}$", "p_cc") +
    prevalence_row("\\quad $p_{nn}$", "p_nn") +
    TexMidrule() +
    TexRow(c("", "subLATE Bounds"), cspan=c(1, 4)) +
    TexMidrule(list(c(2, 5))) +
    TexRow(c("", rep(c("ch-LATE", "nh-LATE"), 2))) +
    TexMidrule(list(c(2, 3), c(4, 5))) +
    TexRow("\\textbf{Bounds}") +
    TexRow("\\quad Lower Bound") /
    TexRow(c(0,
             late_ehscenter,
             0,
             late_abc),
           dec=2) +
    TexRow("\\quad Upper Bound") /
    TexRow(c(late_ehscenter,
             late_ehscenter/prevalence_ehscenter$nh_share,
             late_abc,
             late_abc/prevalence_abc$nh_share),
           dec=2)
  return(tab)
}

tab <- prevalence_sublate_tex()
TexSave(tab, filename="prevalence_bounds", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="prevalence_bounds", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
