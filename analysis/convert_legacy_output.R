# One-off conversion of the estimate files written by the old analysis_table.R
# (wide, unlabelled: causal_output_*, instrumental_output_*, regression_output_*
# with 241 columns, fra_output_* with unlabelled rows, prevalence_output_*)
# into the long, labelled format written by the current analysis_table.R
# (forest_output_*, regression_output_*, fra_output_*, prevalence_output_*).
#
# The estimation in analysis_table.R has bootstrap and random-forest steps that
# are not seeded, so rerunning it would not reproduce the published numbers.
# This script preserves them. It only needs to be run once (September 2026);
# it is kept for the record. Requires preliminary.R (paths and packages).
#
# legacy_dir: folder holding the old files; output_git: where the new files go.
legacy_dir <- paste0(output_git, "legacy/")

programs <- c("ehs-full", "ehsmixed_center", "ehscenter", "abc")
covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf", "poverty")

# Old file suffix (D_var_alt_var) -> participation label
participation_suffixes <- c(any="E_P", `1m`="D_1_P_1", `6m`="D_6_P_6",
                            `12m`="D_12_P_12", `18m`="D_18_P_18")

# Order in which the old analysis_table.R ran the specifications, per program
forest_specifications <- tribble(~subsample, ~covariates,
                                 FALSE,      "all",
                                 FALSE,      "short",
                                 TRUE,       "short")

regression_specifications <- tribble(~subsample, ~method, ~covariates,
                                     FALSE,      "ITT",   "none",
                                     FALSE,      "ITT",   "all",
                                     FALSE,      "ITT",   "short",
                                     FALSE,      "LATE",  "none",
                                     FALSE,      "LATE",  "all",
                                     FALSE,      "LATE",  "short",
                                     TRUE,       "ITT",   "none",
                                     TRUE,       "ITT",   "all",
                                     TRUE,       "ITT",   "short",
                                     TRUE,       "LATE",  "none",
                                     TRUE,       "LATE",  "all",
                                     TRUE,       "LATE",  "short")

# The old code ran the full-sample ITT/short specification twice (its fourth
# call was meant to be LATE/short but omitted method="LATE"); the duplicate is
# dropped, so the converted files have no full-sample LATE/short FRA estimate.
fra_specifications <- tribble(~subsample, ~method, ~covariates,
                              FALSE,      "ITT",   "all",
                              FALSE,      "ITT",   "short",
                              FALSE,      "LATE",  "all",
                              FALSE,      NA,      NA,
                              TRUE,       "ITT",   "all",
                              TRUE,       "ITT",   "short",
                              TRUE,       "LATE",  "all",
                              TRUE,       "LATE",  "short")

for (participation in names(participation_suffixes)) {
  suffix <- participation_suffixes[participation]
  read_legacy <- function(name) {
    read.csv(paste0(legacy_dir, name, "_", suffix, ".csv"))
  }

  # Regression: 12 specifications x 5 statistics per program, side by side
  regression_legacy <- read_legacy("regression_output")
  regression_output <- data.frame()
  for (p in seq_along(programs)) {
    for (s in seq_len(nrow(regression_specifications))) {
      first_column <- 2+60*(p-1)+5*(s-1)
      block <- regression_legacy[, c(1, first_column:(first_column+4))]
      names(block) <- c("variable", "coefficient", "se", "p_value", "F_stat", "N")
      regression_output <-
        bind_rows(regression_output,
                  cbind(data.frame(program=programs[p],
                                   subsample=regression_specifications$subsample[s],
                                   method=regression_specifications$method[s],
                                   covariates=regression_specifications$covariates[s]),
                        block %>% filter(!is.na(coefficient))))
    }
  }

  # Forests: causal_output (ITT) and instrumental_output (LATE), 3 rows per program
  forest_output <- data.frame()
  for (method in c("ITT", "LATE")) {
    forest_legacy <- read_legacy(ifelse(method=="ITT", "causal_output", "instrumental_output"))
    for (p in seq_along(programs)) {
      for (s in seq_len(nrow(forest_specifications))) {
        row <- forest_legacy[3*(p-1)+s, ]
        stopifnot(row$program_from==programs[p],
                  row$subsample==forest_specifications$subsample[s])
        # The plain regression stored alongside the forest is the same estimate as
        # the no-covariate regression in regression_output, so it is not carried over
        regression_row <- regression_output %>%
          filter(program==programs[p], subsample==row$subsample, method==.env$method,
                 covariates=="none", variable==ifelse(method=="ITT", "R", "D"))
        stopifnot(abs(regression_row$coefficient-row$coefficient)<1e-10)
        forest_output <-
          bind_rows(forest_output,
                    data.frame(program=programs[p],
                               subsample=forest_specifications$subsample[s],
                               method=method,
                               covariates=forest_specifications$covariates[s],
                               N=row$N,
                               forest_prediction_mean=row$pre_estimate,
                               forest_ate_estimate=row$pre_dr_estimate,
                               forest_ate_se=row$pre_dr_se,
                               forest_ate_p_value=row$pre_dr_p_value,
                               forest_abc_estimate=row$to_estimate,
                               forest_abc_se=row$to_se,
                               forest_abc_p_value=row$to_p_value))
      }
    }
  }

  # FRA: 8 unlabelled rows per program
  fra_legacy <- read_legacy("fra_output")
  fra_output <- data.frame()
  for (p in seq_along(programs)) {
    for (s in seq_len(nrow(fra_specifications))) {
      if (is.na(fra_specifications$method[s])) next
      fra_output <-
        bind_rows(fra_output,
                  cbind(data.frame(program=programs[p],
                                   subsample=fra_specifications$subsample[s],
                                   method=fra_specifications$method[s],
                                   covariates=fra_specifications$covariates[s]),
                        fra_legacy[8*(p-1)+s, ]))
    }
  }

  # Prevalence: full sample then subsample for each program
  prevalence_output <- read_legacy("prevalence_output") %>%
    add_column(subsample=rep(c(FALSE, TRUE), length(programs)), .after="program")
  stopifnot(prevalence_output$program==rep(programs, each=2))

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
