# ------------------------------------------------------------------ #
# Referee check: is IQ (ppvt3y) availability selective? Check with the
# Achenbach measure (ach3y), EHS files only.
# For each program (EHS All / Center+Mixed / Center Only), estimate the
# ITT (ach3y~R) and LATE (ach3y~E|R) on samples that
#   (1) do not condition on anything,
#   (2) condition on having ppvt3y,
#   (3) condition on having ppvt3y and all covariates (the main
#       analysis sample: clean_data() in analysis_table.R, base
#       participation D=E, alt=P),
#   (4) condition on NOT having ppvt3y,
# then repeat all four on the paper subsample (black, <=HS).
# N is reported for every cell (ITT and LATE separately, since the
# LATE additionally requires E non-missing).
# Run preliminary.R first: it sets data_dir/output_git and loads the
# packages used here (dplyr, ivreg, textab).
# ------------------------------------------------------------------ #

# Conditioning schemes, applied on top of ach3y and R non-missing.
# "Has IQ + covariates" mirrors the clean_data() filter from
# analysis_table.R with iq=ppvt3y.
conditions <- list(
  "Unconditional"=function(df) df,
  "Has IQ"=function(df) df %>% filter(!is.na(iq)),
  "Has IQ + covariates"=function(df) df %>%
    filter(!is.na(iq), !is.na(R), !is.na(E), !is.na(D), !is.na(alt),
           !is.na(m_iq), !is.na(black), !is.na(sex), !is.na(m_age),
           !is.na(sibling), !is.na(gestage), !is.na(mf),
           m_edu %in% c(1, 2, 3), !is.na(poverty)),
  "No IQ"=function(df) df %>% filter(is.na(iq))
)

estimate_cell <- function(df, program, sample_label, condition_label) {
  df_itt <- df %>% filter(!is.na(ach3y), !is.na(R))
  df_late <- df_itt %>% filter(!is.na(E))

  out <- data.frame(program=program, sample=sample_label,
                    condition=condition_label,
                    N_ITT=nrow(df_itt), ctrl_mean=NA,
                    ITT=NA, ITT_se=NA, ITT_p=NA,
                    N_LATE=nrow(df_late), takeup_T=NA, takeup_C=NA,
                    LATE=NA, LATE_se=NA, LATE_p=NA)

  if (nrow(df_itt) >= 10 && n_distinct(df_itt$R) == 2) {
    fit <- summary(lm(ach3y ~ R, data=df_itt))$coefficients
    out$ctrl_mean <- mean(df_itt$ach3y[df_itt$R == 0])
    out$ITT <- fit["R", 1]; out$ITT_se <- fit["R", 2]; out$ITT_p <- fit["R", 4]
  }

  if (nrow(df_late) >= 10 && n_distinct(df_late$R) == 2) {
    takeup_T <- mean(df_late$E[df_late$R == 1])
    takeup_C <- mean(df_late$E[df_late$R == 0])
    out$takeup_T <- takeup_T; out$takeup_C <- takeup_C
    if (takeup_T != takeup_C) {
      iv <- summary(ivreg(ach3y ~ E | R, data=df_late))$coefficients
      out$LATE <- iv["E", 1]; out$LATE_se <- iv["E", 2]
      out$LATE_p <- iv["E", 4]
    }
  }

  out
}

# Test whether the treatment effect in the sample with non-missing IQ
# differs from the one in the unconditional sample. As the former is
# nested in the latter, this is equivalent to testing that the effect
# does not vary with IQ availability, so we report the p-value on the
# treatment x has-IQ interaction (for the LATE, both E and E x has-IQ
# are instrumented by R and R x has-IQ).
p_diff_cell <- function(df, program, sample_label) {
  df <- df %>%
    mutate(has_iq=as.numeric(!is.na(iq))) %>%
    filter(!is.na(ach3y), !is.na(R))
  fit_itt <- summary(lm(ach3y ~ R*has_iq, data=df))$coefficients
  df_late <- df %>% filter(!is.na(E))
  fit_late <- summary(ivreg(ach3y ~ E*has_iq | R*has_iq,
                            data=df_late))$coefficients
  data.frame(program=program, sample=sample_label,
             p_diff_ITT=fit_itt["R:has_iq", 4],
             p_diff_LATE=fit_late["E:has_iq", 4])
}

programs <- c("EHS All"="ehs-full",
              "EHS Center+Mixed"="ehsmixed_center",
              "EHS Center Only"="ehscenter")

results <- data.frame()
p_diff <- data.frame()

for (p in names(programs)) {
  df <- read.csv(paste0(data_dir, programs[p], "-topi.csv")) %>%
    rename(iq=ppvt3y) %>%
    mutate(D=E, alt=P)

  # Subsample conditions on black and m_edu being observed by construction
  df_sub <- df %>% filter(black == 1, m_edu %in% c(1, 2))

  for (cond in names(conditions)) {
    results <- bind_rows(
      results,
      estimate_cell(conditions[[cond]](df), p, "Full", cond),
      estimate_cell(conditions[[cond]](df_sub), p, "Subsample", cond))
  }

  p_diff <- bind_rows(p_diff,
                      p_diff_cell(df, p, "Full"),
                      p_diff_cell(df_sub, p, "Subsample"))
}

cat("\n==== ach3y ITT (ach3y~R) and LATE (ach3y~E|R) by IQ availability ====\n")
print(results %>% mutate(across(where(is.numeric), ~round(., 3))),
      row.names=FALSE)

cat("\n==== p-values: effect in has-IQ sample = effect in unconditional sample ====\n")
print(p_diff %>% mutate(across(where(is.numeric), ~round(., 3))),
      row.names=FALSE)

write.csv(results, paste0(output_git, "referee_achenbach.csv"),
          row.names=FALSE)
write.csv(p_diff, paste0(output_git, "referee_achenbach_pdiff.csv"),
          row.names=FALSE)


# Output to LaTeX table (same format as coefficients_tex, Table 3,
# in analysis_table_tex.R) ####
# Rows kept in the table: No Conditioning and Has IQ, Full and Subsample
table_cells <- expand.grid(sample=c("Full", "Subsample"),
                           condition=c("Unconditional", "Has IQ"),
                           stringsAsFactors=FALSE) %>%
  arrange(desc(sample == "Full"))
condition_labels <- c("Unconditional"="No Conditioning",
                      "Has IQ"="Has IQ")

cell_data <- function(cond, sample_label) {
  results %>%
    filter(condition == cond, sample == sample_label) %>%
    arrange(match(program, names(programs)))
}

estimate_row <- function(cond, sample_label, method="ITT") {
  d <- cell_data(cond, sample_label)
  if (method == "ITT") {
    b <- d$ITT; se <- d$ITT_se; p <- d$ITT_p
  } else if (method == "LATE") {
    b <- d$LATE; se <- d$LATE_se; p <- d$LATE_p
  }
  TexRow(paste0(sample_label, "/", condition_labels[cond])) /
    TexRow(b %>% as.numeric(), pvalues=p %>% as.numeric(), dec=2) +
    TexRow("") /
    TexRow(se %>% as.numeric(), dec=2, se=TRUE)
}

p_diff_row <- function(sample_label, method) {
  d <- p_diff %>%
    filter(sample == sample_label) %>%
    arrange(match(program, names(programs)))
  pvals <- if (method == "ITT") d$p_diff_ITT else d$p_diff_LATE
  TexRow(paste0(sample_label, "/$p$-value: Has IQ $=$ No Conditioning")) /
    TexRow(pvals %>% as.numeric(), dec=3)
}

panel_rows <- function(method) {
  out <- NULL
  for (s in c("Full", "Subsample")) {
    for (cond in c("Unconditional", "Has IQ")) {
      row <- estimate_row(cond, s, method)
      out <- if (is.null(out)) row else out + row
    }
    out <- out + p_diff_row(s, method)
    if (s == "Full") out <- out + TexMidrule(list(c(1, 1), c(2, 4)))
  }
  return(out)
}

sample_size_rows <- function() {
  out <- NULL
  for (i in seq_len(nrow(table_cells))) {
    d <- cell_data(table_cells$condition[i], table_cells$sample[i])
    row <- TexRow(paste0("Sample Size: ", table_cells$sample[i], "/",
                         condition_labels[table_cells$condition[i]])) /
      TexRow(d$N_ITT %>% as.numeric(), dec=0)
    out <- if (is.null(out)) row else out + row
  }
  return(out)
}

tab <- TexRow(c("Program ", "EHS"), cspan=c(1, 3)) +
  TexMidrule(list(c(2, 4))) +
  TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only")) +
  TexMidrule() +
  TexRow(c("", "ITT"), cspan=c(1, 3)) +
  TexMidrule(list(c(2, 4))) +
  panel_rows("ITT") +
  TexMidrule() +
  TexMidrule() +
  TexRow(c("", "LATE"), cspan=c(1, 3)) +
  TexMidrule(list(c(2, 4))) +
  panel_rows("LATE") +
  TexMidrule() +
  TexMidrule() +
  sample_size_rows()

TexSave(tab, filename="referee_achenbach", positions=c('l', rep('c', 3)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="referee_achenbach", positions=c('l', rep('c', 3)),
        output_path=output_git, stand_alone=FALSE)
TexSave(tab, filename="referee_achenbach_standalone", positions=c('l', rep('c', 3)),
        output_path=output_git, stand_alone=TRUE)
