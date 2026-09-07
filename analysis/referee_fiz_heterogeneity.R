# ------------------------------------------------------------------ #
# Referee check (Reviewer 1, CK): Fort, Ichino & Zanella (2020) pattern
# Exhaustive subgroup breakdown of ITT (iq~R) and LATE (iq~E|R) by all
# combinations of three binary splits:
#   m_edu_hs_or_above : 1 = mother completed HS or above (m_edu 2,3),
#                       0 = less than HS (m_edu 1)
#   above_poverty     : 1 = income above poverty line (poverty variable)
#   black             : 1 = Black, 0 = non-Black (imputed fractional
#                       values drop out of conditioned cells)
# A blank value means the cell does not condition on that variable, so
# rows cover the full sample, marginals, pairwise, and three-way cells.
# The group column adds labeled rows outside this grid: the paper's
# subsample (Black, mother at most HS), its complement, and whites
# (race==1 in EHS, race==2 in ABC; imputed fractional black values fall
# in the complement).
# Samples: EHS All / Center+Mixed / Center Only (PPVT 36m) and ABC
# (Stanford-Binet 36m). Mirrors clean_data() and the base participation
# definition (D=E, alt=P) from analysis_table.R.
# Run preliminary.R first: it provides data_dir, output_git, and packages
# (haven, used for the race merge, is called via its namespace).
# ------------------------------------------------------------------ #

MIN_N <- 15

# Same filter as clean_data() in analysis_table.R (base case D=E, alt=P)
clean_data <- function(df) {
  df %>%
    filter(!is.na(iq), !is.na(R), !is.na(E), !is.na(D), !is.na(alt),
           !is.na(m_iq), !is.na(black), !is.na(sex), !is.na(m_age),
           !is.na(sibling), !is.na(gestage), !is.na(mf),
           m_edu %in% c(1, 2, 3), !is.na(poverty))
}

# Manual 2SLS (just-identified, classical SEs; matches ivreg defaults)
tsls <- function(y, endog, instr) {
  n <- length(y)
  X <- cbind(1, endog)
  Z <- cbind(1, instr)
  XZ <- solve(crossprod(Z, X))
  beta <- XZ %*% crossprod(Z, y)
  res <- y - X %*% beta
  sigma2 <- sum(res^2) / (n - 2)
  V <- sigma2 * XZ %*% crossprod(Z) %*% t(XZ)
  b <- beta[2]; se <- sqrt(V[2, 2])
  c(b=b, se=se, p=2 * pt(-abs(b / se), df=n - 2))
}

cell_estimates <- function(df) {
  empty <- c(ITT=NA, ITT_se=NA, ITT_p=NA, LATE=NA, LATE_se=NA, LATE_p=NA)
  if (nrow(df) < MIN_N || length(unique(df$R)) < 2) return(empty)
  fit <- summary(lm(iq ~ R, data=df))$coefficients
  iv <- tryCatch(unname(tsls(df$iq, df$E, df$R)),
                 error=function(e) rep(NA, 3))
  c(ITT=fit[2, 1], ITT_se=fit[2, 2], ITT_p=fit[2, 4],
    LATE=iv[1], LATE_se=iv[2], LATE_p=iv[3])
}

# All combinations of {unconditioned, 0, 1} for the three binaries,
# ordered from coarse (full sample) to granular (three-way cells)
splits <- expand.grid(m_edu_hs_or_above=c(NA, 0, 1),
                      above_poverty=c(NA, 0, 1),
                      black=c(NA, 0, 1)) %>%
  mutate(n_cond=(!is.na(m_edu_hs_or_above)) + (!is.na(above_poverty)) +
           (!is.na(black))) %>%
  arrange(n_cond, !is.na(m_edu_hs_or_above), !is.na(above_poverty),
          !is.na(black), desc(m_edu_hs_or_above), desc(above_poverty),
          desc(black)) %>%
  select(-n_cond)

sample_breakdown <- function(df, label) {
  df <- df %>%
    mutate(m_edu_hs_or_above=as.numeric(m_edu %in% c(2, 3)),
           above_poverty=poverty,
           subsample=black == 1 & m_edu %in% c(1, 2))
  out <- data.frame()
  for (i in seq_len(nrow(splits))) {
    cell <- df
    for (v in c("m_edu_hs_or_above", "above_poverty", "black")) {
      if (!is.na(splits[i, v])) cell <- cell[cell[[v]] == splits[i, v], ]
    }
    est <- cell_estimates(cell)
    out <- bind_rows(out, data.frame(sample=label, group="",
                                     splits[i, ],
                                     N=nrow(cell), t(est), row.names=NULL))
  }
  labeled <- list("Subsample (Black, mother <=HS)"=filter(df, subsample),
                  "Complement of subsample"=filter(df, !subsample),
                  "White"=filter(df, white == 1))
  for (g in names(labeled)) {
    cell <- labeled[[g]]
    out <- bind_rows(out, data.frame(sample=label, group=g,
                                     m_edu_hs_or_above=NA, above_poverty=NA,
                                     black=NA, N=nrow(cell),
                                     t(cell_estimates(cell)), row.names=NULL))
  }
  out
}

samples_ehs <- c("EHS All"="ehs-full",
                 "EHS Center+Mixed"="ehsmixed_center",
                 "EHS Center Only"="ehscenter")

# Race is not in the merged working CSVs; take it from the control files.
# EHS: 1=White, 2=Black, 3=Hispanic, 4=Other; ABC: 1=Black, 2=White, 3=Other.
race_ehs <- haven::read_dta(paste0(data_dir, "ehs-control.dta")) %>%
  transmute(id=as.character(as.numeric(id)),
            white=as.numeric(as.numeric(race) == 1))
race_abc <- haven::read_dta(paste0(data_dir, "abc-control.dta")) %>%
  transmute(id=as.character(as.numeric(id)),
            white=as.numeric(as.numeric(race) == 2))

results <- data.frame()
for (s in names(samples_ehs)) {
  df <- read.csv(paste0(data_dir, samples_ehs[s], "-topi.csv")) %>%
    rename(iq=ppvt3y) %>%
    mutate(D=E, alt=P, id=as.character(id)) %>%
    left_join(race_ehs, by="id") %>%
    clean_data()
  results <- bind_rows(results, sample_breakdown(df, s))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(E=D, alt=P, id=as.character(id)) %>%
  rename(iq=sb3y) %>%
  left_join(race_abc, by="id") %>%
  clean_data()
results <- bind_rows(results, sample_breakdown(abc, "ABC"))

print(results %>% mutate(across(where(is.numeric), ~round(., 3))),
      row.names=FALSE)

write.csv(results, paste0(output_git, "referee_fiz_heterogeneity.csv"),
          row.names=FALSE)
