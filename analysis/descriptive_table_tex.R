start_time <- Sys.time()

# Sample selection counts, descriptive statistics, and balance tables.
# Every summary is a long data frame labelled by
#   program: "ehs-full", "ehsmixed_center", "ehscenter", "abc"
#   sample:  "full" or "subsample" (black children, mothers without college)
#   variable (or type, for the counts)
# so the table code picks each cell by name.

covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf", "poverty")
covariates_subsample_all <- c("m_iq", "sex", "m_age",
                              "sibling", "gestage", "mf", "poverty")
covariates_short <- c("m_iq", "m_age")

# Columns of the descriptive and count tables, in table order
table_columns <- expand_grid(program=c("ehs-full", "ehsmixed_center", "ehscenter", "abc"),
                             sample=c("full", "subsample"))

clean_data <- function(df, subsample=FALSE) {
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

# Sample selection: number (n) and share (p, in percent) of observations remaining
# after each successive requirement
count_summary_data <- function(program, subsample=FALSE) {
  if (subsample) {
    program <- program %>%
      filter(black==1,
             m_edu %in% c(1, 2))
  }

  program <- program %>%
    mutate(has_R=!is.na(R),
           has_iq=has_R & !is.na(iq),
           has_covariates=has_iq &
             !is.na(m_iq) &
             !is.na(black) &
             !is.na(sex) &
             !is.na(m_age) &
             !is.na(sibling) &
             !is.na(gestage) &
             !is.na(mf) &
             m_edu %in% c(1, 2, 3) &
             !is.na(poverty),
           has_E=has_covariates & !is.na(E),
           has_D=has_E & !is.na(D),
           has_alt=has_D & !is.na(alt))

  count_table <- data.frame(type=c("all", "iq", "covariates", "E", "D", "alt"),
                            n=c(sum(program$has_R),
                                sum(program$has_iq),
                                sum(program$has_covariates),
                                sum(program$has_E),
                                sum(program$has_D),
                                sum(program$has_alt))) %>%
    mutate(p=n/sum(program$has_R)*100)

  return(count_table)
}

# Descriptive statistics: mean of each variable (shares for binary variables)
descriptive_summary_data <- function(program) {
  descriptive_table <- program %>%
    summarise(iq=mean(iq_orig, na.rm=TRUE),
              random=sum(R, na.rm=TRUE)/n(),
              participation_E=sum(E, na.rm=TRUE)/n(),
              participation_D=sum(D, na.rm=TRUE)/n(),
              alternative=sum(alt, na.rm=TRUE)/n(),
              sex=sum(sex, na.rm=TRUE)/n(),
              black=sum(black, na.rm=TRUE)/n(),
              sibling=mean(sibling, na.rm=TRUE),
              gestage=mean(gestage, na.rm=TRUE),
              m_iq=mean(m_iq, na.rm=TRUE),
              m_age=mean(m_age, na.rm=TRUE),
              m_edu_2=sum(m_edu_2, na.rm=TRUE)/n(),
              m_edu_3=sum(m_edu_3, na.rm=TRUE)/n(),
              mf=mean(mf, na.rm=TRUE),
              poverty=sum(poverty, na.rm=TRUE)/n(),
              n=n()) %>%
    ungroup() %>%
    pivot_longer(everything(), names_to="variable", values_to="value")

  return(descriptive_table)
}

# Balance: treatment mean, control mean, and p-value of the difference for each covariate
balance_summary_data <- function(program) {
  balance_table <- data.frame()
  for (var in covariates_all) {
    treat <- program %>% filter(R==1) %>% pull(all_of(var))
    control <- program %>% filter(R==0) %>% pull(all_of(var))
    if (sd(treat)==0 | sd(control)==0) {
      diff_p <- 1
    } else {
      diff_p <- t.test(treat, control)$p.value
    }
    balance_table <- rbind(balance_table,
                           data.frame(variable=var,
                                      value_treatment=mean(treat, na.rm=TRUE),
                                      value_control=mean(control, na.rm=TRUE),
                                      p_value=diff_p))
  }

  balance_table <- rbind(balance_table,
                         data.frame(variable="n",
                                    value_treatment=sum(program$R==1),
                                    value_control=sum(program$R==0),
                                    p_value=NA))
  return(balance_table)
}


# Execute! ####
# Load data
programs_ehs <- c("ehs-full", "ehsmixed_center", "ehscenter")
programs <- c(programs_ehs, "abc")

for (p in programs_ehs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
                  m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA)) %>%
           rename(iq=ppvt3y,
                  iq_orig=iq_orig))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(D=D_12,
         E=D_12,
         alt=P_12,
         m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
         m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA),
         caregiver_home=1) %>%
  rename(iq=sb3y,
         iq_orig=iq_orig)

`ehs-full` <- `ehs-full` %>%
  mutate(caregiver_home=caregiver_ever,
         D=D_12,
         alt=P_12,
         H=ifelse(D==1, 4140/6000, ifelse(D==0, 0, NA)))

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

# Attrition
attrition_results <- data.frame()

for (p in programs) {
  assign(p,
         get(p) %>%
           mutate(M=is.na(iq)))
}

for (p in programs) {
  fit <- (lm(as.formula(paste0("M~R+",
                               paste(covariates_all, collapse="+"))),
             data=get(p)) %>% summary())$coefficients

  attrition_results <- rbind(attrition_results,
                             data.frame(program=p,
                                        estimate=round(fit["R", "Estimate"], 3),
                                        std_error=round(fit["R", "Std. Error"], 3),
                                        p_value=round(fit["R", "Pr(>|t|)"], 3)))
}

# Summaries for every (program, sample) column
number_counts <- data.frame()
descriptive_summary <- data.frame()
balance_summary <- data.frame()

for (i in seq_len(nrow(table_columns))) {
  program <- table_columns$program[i]
  sample <- table_columns$sample[i]
  subsample <- sample=="subsample"
  labels <- data.frame(program=program, sample=sample)

  number_counts <-
    rbind(number_counts,
          cbind(labels, count_summary_data(get(program), subsample)))
  descriptive_summary <-
    rbind(descriptive_summary,
          cbind(labels, descriptive_summary_data(clean_data(get(program), subsample))))
  balance_summary <-
    rbind(balance_summary,
          cbind(labels, balance_summary_data(clean_data(get(program), subsample))))
}


# Output to LaTeX tables ####
# Values of one statistic for every (program, sample) column, in table order;
# `result` must hold one row per column
column_values <- function(result, statistic) {
  table_columns %>%
    left_join(result, by=c("program", "sample")) %>%
    pull(all_of(statistic))
}

# Header shared by the count and descriptive tables
program_header <- function() {
  TexRow(c("Program", "EHS", "ABC"), cspan=c(1, 6, 2)) +
    TexMidrule(list(c(1, 1), c(2, 7), c(8, 9))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 2, 2, 2, 2)) +
    TexMidrule(list(c(1, 1), c(2, 3), c(4, 5), c(6, 7), c(8, 9))) +
    TexRow(c("Sample", rep(c("Full", "Subsample"), 4))) +
    TexMidrule()
}

# Sample selection counts: number of observations, then share in percent
number_counts_tex <- function() {
  count_rows <- function(label, type) {
    counts <- number_counts %>% filter(type==.env$type)
    TexRow(label) /
      TexRow(column_values(counts, "n"), dec=0) +
      TexRow("") /
      TexRow(column_values(counts, "p"), dec=0, se=TRUE, percentage=TRUE)
  }

  tab <- program_header() +
    count_rows("All", "all") +
    count_rows("Non-Missing Outcome", "iq") +
    count_rows("Non-Missing Covariates", "covariates") +
    count_rows("Non-Missing Participation (Any)", "E") +
    count_rows("Non-Missing Participation (Center)", "D") +
    count_rows("Non-Missing Alternate Care", "alt")
  return(tab)
}

tab <- number_counts_tex()
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 8)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 8)),
        output_path=output_git, stand_alone=FALSE)

# Descriptive statistics
descriptive_stat_tex <- function() {
  descriptive_row <- function(label, variable, percentage=FALSE, dec=1) {
    values <- column_values(descriptive_summary %>% filter(variable==.env$variable), "value")
    TexRow(paste0("\\quad ", label)) /
      TexRow(values*ifelse(percentage, 100, 1), dec=dec)
  }

  tab <- program_header() +
    TexRow("\\textbf{Outcome}") +
    descriptive_row("IQ", "iq") +
    TexRow("") +
    TexRow("\\textbf{Assignment and Participation}") +
    descriptive_row("\\% Randomized", "random", percentage=TRUE) +
    descriptive_row("\\% Participated (Any)", "participation_E", percentage=TRUE) +
    descriptive_row("\\% Participated (Center)", "participation_D", percentage=TRUE) +
    descriptive_row("\\% Alternative Care", "alternative", percentage=TRUE) +
    TexRow("") +
    TexRow("\\textbf{Children's Characteristics}") +
    descriptive_row("\\% Male", "sex", percentage=TRUE) +
    descriptive_row("\\% Black", "black", percentage=TRUE) +
    descriptive_row("\\# Siblings", "sibling") +
    descriptive_row("Gestational Age (Weeks)", "gestage") +
    TexRow("") +
    TexRow("\\textbf{Mother's Characteristics}") +
    descriptive_row("Mother's IQ", "m_iq") +
    descriptive_row("Mother's Age", "m_age") +
    descriptive_row("\\% HS Completed", "m_edu_2", percentage=TRUE) +
    descriptive_row("\\% College Completed", "m_edu_3", percentage=TRUE) +
    descriptive_row("\\% Father Figure at Home", "mf", percentage=TRUE) +
    descriptive_row("\\% Above Poverty", "poverty", percentage=TRUE) +
    TexRow("") +
    TexRow("\\textbf{Sample Size}") +
    descriptive_row("\\# Observations", "n", dec=0)
  return(tab)
}

tab <- descriptive_stat_tex()
TexSave(tab, filename="descriptive_stats", positions=c('l', rep('c', 8)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="descriptive_stats", positions=c('l', rep('c', 8)),
        output_path=output_git, stand_alone=FALSE)

# Balance table for one program: treatment mean, control mean, p-value
# of the difference, for the full sample and the subsample
descriptive_stat_balance_tex <- function(program) {
  balance_result <- balance_summary %>% filter(program==.env$program)

  # Full-sample then subsample values of one variable, as (T, C, p)
  balance_values <- function(variable, scale=1) {
    values <- c()
    for (sample in c("full", "subsample")) {
      row <- balance_result %>% filter(variable==.env$variable, sample==.env$sample)
      values <- c(values, row$value_treatment*scale, row$value_control*scale, row$p_value)
    }
    return(values)
  }

  balance_row <- function(label, variable, percentage=FALSE) {
    TexRow(paste0("\\quad ", label)) /
      TexRow(balance_values(variable, scale=ifelse(percentage, 100, 1)),
             dec=rep(c(1, 1, 2), 2), percentage=rep(c(percentage, percentage, FALSE), 2))
  }

  tab <- TexRow(c("Sample", "Full", "Subsample"), cspan=c(1, 3, 3)) +
    TexMidrule(list(c(1, 1), c(2, 4), c(5, 7))) +
    TexRow(c("", rep(c("T", "C", "$p(\\Delta)$"), 2))) +
    TexMidrule() +
    TexRow("\\textbf{Children's Characteristics}") +
    balance_row("\\% Male", "sex", percentage=TRUE) +
    balance_row("\\% Black", "black", percentage=TRUE) +
    balance_row("\\# Siblings", "sibling") +
    balance_row("Gestational Age (Weeks)", "gestage") +
    TexRow("") +
    TexRow("\\textbf{Mother's Characteristics}") +
    balance_row("Mother's IQ", "m_iq") +
    balance_row("Mother's Age", "m_age") +
    balance_row("\\% HS Completed", "m_edu_2", percentage=TRUE) +
    balance_row("\\% College Completed", "m_edu_3", percentage=TRUE) +
    balance_row("\\% Father Figure at Home", "mf", percentage=TRUE) +
    balance_row("\\% Above Poverty", "poverty", percentage=TRUE) +
    TexRow("") +
    TexRow("\\textbf{Sample Size}") +
    TexRow("\\quad \\# Observations") /
    TexRow(balance_values("n"), dec=0, percentage=FALSE)
  return(tab)
}

balance_filenames <- c(`ehs-full`="descriptive_stats_balance_ehs_full",
                       ehsmixed_center="descriptive_stats_balance_ehsmixed_center",
                       ehscenter="descriptive_stats_balance_ehscenter",
                       abc="descriptive_stats_balance_abc")

for (p in programs) {
  tab <- descriptive_stat_balance_tex(p)
  TexSave(tab, filename=balance_filenames[p], positions=c('l', rep('c', 6)),
          output_path=output_dir, stand_alone=FALSE)
  TexSave(tab, filename=balance_filenames[p], positions=c('l', rep('c', 6)),
          output_path=output_git, stand_alone=FALSE)
}

# Subgroup means: baseline characteristics by mother's education and race in
# the full EHS sample (complete-case sample, as in the descriptive table).
# The HOME score is measured at 36 months, after random assignment, so it is
# averaged over control children only.
subgroup_columns <- data.frame(group=c("black_low", "nonblack_low", "black_high", "nonblack_high"),
                               black=c(1, 0, 1, 0),
                               college=c(FALSE, FALSE, TRUE, TRUE))

subgroup_summary_data <- function(program) {
  subgroup_table <- data.frame()
  for (i in seq_len(nrow(subgroup_columns))) {
    group <- program %>%
      filter(black==subgroup_columns$black[i],
             (m_edu==3)==subgroup_columns$college[i])
    subgroup_table <-
      rbind(subgroup_table,
            data.frame(group=subgroup_columns$group[i],
                       variable=c("m_iq", "m_age", "mf", "poverty", "home"),
                       value=c(mean(group$m_iq),
                               mean(group$m_age),
                               mean(group$mf),
                               mean(group$poverty),
                               mean(group$home_total36[group$R==0], na.rm=TRUE))))
  }
  return(subgroup_table)
}

subgroup_summary <- subgroup_summary_data(clean_data(`ehs-full`))

subgroup_means_tex <- function() {
  # Values of one statistic for the four subgroups, in table order
  subgroup_values <- function(variable) {
    subgroup_columns %>%
      left_join(subgroup_summary %>% filter(variable==.env$variable), by="group") %>%
      pull(value)
  }

  subgroup_row <- function(label, variable, percentage=FALSE) {
    TexRow(label) /
      TexRow(subgroup_values(variable)*ifelse(percentage, 100, 1), dec=1)
  }

  tab <- TexRow(c("Mother's Education", "No College", "College"), cspan=c(1, 2, 2)) +
    TexMidrule(list(c(1, 1), c(2, 3), c(4, 5))) +
    TexRow(c("Race", rep(c("Black", "Non-Black"), 2))) +
    TexMidrule() +
    subgroup_row("Mother's IQ", "m_iq") +
    subgroup_row("Mother's Age", "m_age") +
    subgroup_row("\\% Father Figure at Home", "mf", percentage=TRUE) +
    subgroup_row("\\% Above Poverty", "poverty", percentage=TRUE) +
    subgroup_row("\\% HOME Items (Control Group)", "home", percentage=TRUE)
  return(tab)
}

tab <- subgroup_means_tex()
TexSave(tab, filename="subgroup_means", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="subgroup_means", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
