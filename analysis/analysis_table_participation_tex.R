start_time <- Sys.time()

# Load estimates ####
# Center Only subsample LATE by participation definition (at least 1, 6, 12, 18 months)
participation_definitions <- c("1m", "6m", "12m", "18m")

load_output <- function(name) {
  bind_rows(lapply(participation_definitions, function(participation) {
    read.csv(paste0(output_git, name, "_", participation, ".csv"))
  }))
}

forest_output <- load_output("forest_output")
regression_output <- load_output("regression_output")

# Estimates in participation-definition order, one column each
# 2SLS without covariates: coefficient on D
late_regression <- regression_output %>%
  filter(program=="ehscenter", subsample==TRUE, method=="LATE", covariates=="none",
         variable=="D") %>%
  arrange(match(participation, participation_definitions))

# Instrumental forest (mother's IQ and age) predicted on ABC covariates
late_forest_abc <- forest_output %>%
  filter(program=="ehscenter", subsample==TRUE, method=="LATE", covariates=="short") %>%
  arrange(match(participation, participation_definitions))


# TeX table ####
tab <- TexRow(c("Participation", participation_definitions)) +
  TexMidrule() +
  TexRow("LATE - Center Only (Subsample)") /
  TexRow(late_regression$coefficient,
         pvalues=late_regression$p_value,
         dec=2) +
  TexRow("") /
  TexRow(late_regression$se,
         dec=2, se=TRUE) +
  TexRow("LATE - Instrumental Forest (ABC)") /
  TexRow(late_forest_abc$forest_abc_estimate,
         pvalues=late_forest_abc$forest_abc_p_value,
         dec=2) +
  TexRow("") /
  TexRow(late_forest_abc$forest_abc_se,
         dec=2, se=TRUE)

TexSave(tab, filename="progress_participation", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="progress_participation", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
