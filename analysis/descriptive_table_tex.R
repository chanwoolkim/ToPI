start_time <- Sys.time()

covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf", "poverty")
covariates_subsample_all <- c("m_iq", "sex", "m_age",
                              "sibling", "gestage", "mf", "poverty")
covariates_short <- c("m_iq", "m_age")

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

# Table of counts for missing data
count_summary_data <- function(program, subsample=FALSE) {
  if (subsample) {
    program <- program %>%
      filter(black==1,
             m_edu %in% c(1, 2))
  }
  
  count_table <- program %>%
    summarise(n_all=sum(!is.na(R)),
              n_covariates=sum(!is.na(R) &
                                 !is.na(m_iq) &
                                 !is.na(black) &
                                 !is.na(sex) &
                                 !is.na(m_age) &
                                 !is.na(sibling) &
                                 !is.na(gestage) &
                                 !is.na(mf) &
                                 m_edu %in% c(1, 2, 3) &
                                 !is.na(poverty)),
              n_E=sum(!is.na(R) &
                        !is.na(m_iq) &
                        !is.na(black) &
                        !is.na(sex) &
                        !is.na(m_age) &
                        !is.na(sibling) &
                        !is.na(gestage) &
                        !is.na(mf) &
                        m_edu %in% c(1, 2, 3) &
                        !is.na(poverty) &
                        !is.na(E)),
              n_D=sum(!is.na(R) &
                        !is.na(m_iq) &
                        !is.na(black) &
                        !is.na(sex) &
                        !is.na(m_age) &
                        !is.na(sibling) &
                        !is.na(gestage) &
                        !is.na(mf) &
                        m_edu %in% c(1, 2, 3) &
                        !is.na(poverty) &
                        !is.na(D) &
                        !is.na(E)),
              n_alt=sum(!is.na(R) &
                          !is.na(m_iq) &
                          !is.na(black) &
                          !is.na(sex) &
                          !is.na(m_age) &
                          !is.na(sibling) &
                          !is.na(gestage) &
                          !is.na(mf) &
                          m_edu %in% c(1, 2, 3) &
                          !is.na(poverty) &
                          !is.na(D) &
                          !is.na(E) &
                          !is.na(alt)),
              n_iq=sum(!is.na(R) &
                         !is.na(m_iq) &
                         !is.na(black) &
                         !is.na(sex) &
                         !is.na(m_age) &
                         !is.na(sibling) &
                         !is.na(gestage) &
                         !is.na(mf) &
                         m_edu %in% c(1, 2, 3) &
                         !is.na(poverty) &
                         !is.na(D) &
                         !is.na(E) &
                         !is.na(alt) &
                         !is.na(iq))) %>%
    ungroup() %>%
    mutate(p_all=n_all/n_all*100,
           p_covariates=n_covariates/n_all*100,
           p_E=n_E/n_all*100,
           p_D=n_D/n_all*100,
           p_alt=n_alt/n_all*100,
           p_iq=n_iq/n_all*100) %>%
    pivot_longer(everything(),
                 names_to=c(".value", "type"),
                 names_sep="_") %>%
    select(type, n, p)
  
  if (subsample) {
    count_table <- count_table %>%
      mutate(sample="subsample")
  } else {
    count_table <- count_table %>%
      mutate(sample="full")
  }
  
  return(count_table)
}

# Table of descriptive statistics
descriptive_summary_data <- function(program, balance=FALSE) {
  if (balance) {
    descriptive_table <- data.frame()
    for (var in covariates_all) {
      treat <- program %>% filter(R==1) %>% select(all_of(var)) %>% pull()
      control <- program %>% filter(R==0) %>% select(all_of(var)) %>% pull()
      if (sd(treat)==0 | sd(control)==0) {
        diff_p <- 1
      } else {
        diff_p <- t.test(treat, control)$p.value
      }
      descriptive_table <- rbind(descriptive_table,
                                 data.frame(var=var,
                                            value_treatment=mean(treat, na.rm=TRUE),
                                            value_control=mean(control, na.rm=TRUE),
                                            p_value=diff_p))
    }
    n_descriptive_table <- program %>% group_by(R) %>% summarise(n=n()) %>% ungroup()
    descriptive_table <- 
      rbind(descriptive_table,
            data.frame(var="n",
                       value_treatment=n_descriptive_table %>% filter(R==1) %>% select(n) %>% pull(),
                       value_control=n_descriptive_table %>% filter(R==0) %>% select(n) %>% pull(),
                       p_value=NA))
  } else {
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
      ungroup()
    descriptive_table <- data.frame(value=descriptive_table[1,] %>% as.numeric())
  }
  
  return(descriptive_table)
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

# Missing data
number_counts <- 
  rbind(count_summary_data(`ehs-full`) %>% mutate(program="ehs-full"),
        count_summary_data(`ehs-full`, subsample=TRUE) %>% mutate(program="ehs-full"),
        count_summary_data(ehsmixed_center) %>% mutate(program="ehsmixed_center"),
        count_summary_data(ehsmixed_center, subsample=TRUE) %>% mutate(program="ehsmixed_center"),
        count_summary_data(ehscenter) %>% mutate(program="ehscenter"),
        count_summary_data(ehscenter, subsample=TRUE) %>% mutate(program="ehscenter"),
        count_summary_data(abc) %>% mutate(program="abc"),
        count_summary_data(abc, subsample=TRUE) %>% mutate(program="abc"))

descriptive_summary <-
  cbind(data.frame(rowname=c("IQ",
                             "\\% Randomized",
                             "\\% Participated (Any)",
                             "\\% Participated (Center)",
                             "\\% Alternative Care",
                             "\\% Male",
                             "\\% Black", 
                             "\\# Siblings", 
                             "Gestational Age (Weeks)",
                             "Mother's IQ",
                             "Mother's Age",
                             "\\% HS Completed",
                             "\\% College Completed",
                             "\\% Father Figure at Home",
                             "\\% Above Poverty",
                             "\\# Observations")),
        descriptive_summary_data(clean_data(`ehs-full`)),
        descriptive_summary_data(clean_data(`ehs-full`, subsample=TRUE)),
        descriptive_summary_data(clean_data(ehsmixed_center)),
        descriptive_summary_data(clean_data(ehsmixed_center, subsample=TRUE)),
        descriptive_summary_data(clean_data(ehscenter)),
        descriptive_summary_data(clean_data(ehscenter, subsample=TRUE)),
        descriptive_summary_data(clean_data(abc)),
        descriptive_summary_data(clean_data(abc, subsample=TRUE)))

descriptive_balance_summary <- 
  rbind(descriptive_summary_data(clean_data(`ehs-full`), balance=TRUE) %>%
          mutate(sample="full", program="ehs-full"),
        descriptive_summary_data(clean_data(`ehs-full`, subsample=TRUE), balance=TRUE) %>%
          mutate(sample="subsample", program="ehs-full"),
        descriptive_summary_data(clean_data(ehsmixed_center), balance=TRUE) %>%
          mutate(sample="full", program="ehsmixed_center"),
        descriptive_summary_data(clean_data(ehsmixed_center, subsample=TRUE), balance=TRUE) %>%
          mutate(sample="subsample", program="ehsmixed_center"),
        descriptive_summary_data(clean_data(ehscenter), balance=TRUE) %>%
          mutate(sample="full", program="ehscenter"),
        descriptive_summary_data(clean_data(ehscenter, subsample=TRUE), balance=TRUE) %>%
          mutate(sample="subsample", program="ehscenter"),
        descriptive_summary_data(clean_data(abc), balance=TRUE) %>%
          mutate(sample="full", program="abc"),
        descriptive_summary_data(clean_data(abc, subsample=TRUE), balance=TRUE) %>%
          mutate(sample="subsample", program="abc"))


# Output to LaTeX tables ####
number_counts_tex <- function(counts_result) {
  number_counts_type_tex <- function(var_type, var_typename) {
    tab <- TexRow(var_typename) /
      TexRow(counts_result %>% filter(type==var_type) %>% pull(n), dec=0) +
      TexRow("") /
      TexRow(counts_result %>% filter(type==var_type) %>% pull(p), 
             dec=0, se=TRUE, percentage=TRUE)
    return(tab)
  }
  
  tab <- TexRow(c("Program", "EHS", "ABC"), cspan=c(1, 6, 2)) +
    TexMidrule(list(c(1, 1), c(2, 7), c(8, 9))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 2, 2, 2, 2)) +
    TexMidrule(list(c(1, 1), c(2, 3), c(4, 5), c(6, 7), c(8, 9))) +
    TexRow(c("Sample", rep(c("Full", "Subsample"), 4))) +
    TexMidrule() +
    number_counts_type_tex("all", "All") +
    number_counts_type_tex("covariates", "Non-Missing Covariates") +
    number_counts_type_tex("E", "Non-Missing Participation (Any)") +
    number_counts_type_tex("D", "Non-Missing Participation (Center)") +
    number_counts_type_tex("alt", "Non-Missing Alternate Care") +
    number_counts_type_tex("iq", "Non-Missing Outcome")
  return(tab)
}

tab <- number_counts_tex(number_counts)
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 8)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 8)),
        output_path=output_git, stand_alone=FALSE)

descriptive_stat_tex <- function(descriptive_result) {
  tab <- TexRow(c("Program", "EHS", "ABC"), 
                cspan=c(1, 6, 2)) +
    TexMidrule(list(c(1, 1), c(2, 7), c(8, 9))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), 
           cspan=c(1, 2, 2, 2, 2)) +
    TexMidrule(list(c(1, 1), c(2, 3), c(4, 5), c(6, 7), c(8, 9))) +
    TexRow(c("Sample", rep(c("Full", "Subsample"), 4))) +
    TexMidrule() +
    TexRow("\\textbf{Outcome}") +
    TexRow(paste0("\\quad ", descriptive_result[1, 1])) / 
    TexRow((descriptive_result[1, 2:9] %>% as.numeric()), dec=1) +
    TexRow("") +
    TexRow("\\textbf{Assignment and Participation}") +
    TexRow(paste0("\\quad ", descriptive_result[2, 1])) /
    TexRow((descriptive_result[2, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[3, 1])) /
    TexRow((descriptive_result[3, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[4, 1])) /
    TexRow((descriptive_result[4, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[5, 1])) /
    TexRow((descriptive_result[5, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow("") +
    TexRow("\\textbf{Children's Characteristics}") +
    TexRow(paste0("\\quad ", descriptive_result[6, 1])) /
    TexRow((descriptive_result[6, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[7, 1])) /
    TexRow((descriptive_result[7, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[8, 1])) /
    TexRow((descriptive_result[8, 2:9] %>% as.numeric()), dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[9, 1])) / 
    TexRow((descriptive_result[9, 2:9] %>% as.numeric()), dec=1) +
    TexRow("") +
    TexRow("\\textbf{Mother's Characteristics}") +
    TexRow(paste0("\\quad ", descriptive_result[10, 1])) /
    TexRow((descriptive_result[10, 2:9] %>% as.numeric()), dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[11, 1])) /
    TexRow((descriptive_result[11, 2:9] %>% as.numeric()), dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[12, 1])) /
    TexRow((descriptive_result[12, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[13, 1])) /
    TexRow((descriptive_result[13, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[14, 1])) /
    TexRow((descriptive_result[14, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[15, 1])) /
    TexRow((descriptive_result[15, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow("") +
    TexRow("\\textbf{Sample Size}") +
    TexRow(paste0("\\quad ", descriptive_result[16, 1])) /
    TexRow((descriptive_result[16, 2:9] %>% as.numeric()), dec=0)
  return(tab)
}

tab <- descriptive_stat_tex(descriptive_summary)
TexSave(tab, filename="descriptive_stats", positions=c('l', rep('c', 8)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="descriptive_stats", positions=c('l', rep('c', 8)),
        output_path=output_git, stand_alone=FALSE)

descriptive_stat_balance_tex <- function(descriptive_result) {
  tab_row <- function(varname, proportion=FALSE) {
    if (proportion) {
      tab <- TexRow(c((descriptive_result %>% 
                         filter(var==varname, sample=="full"))[, 2:3] %>%
                        as.numeric()*100,
                      (descriptive_result %>% 
                         filter(var==varname, sample=="full"))[, 4] %>%
                        as.numeric(),
                      (descriptive_result %>% 
                         filter(var==varname, sample=="subsample"))[, 2:3] %>%
                        as.numeric()*100,
                      (descriptive_result %>% 
                         filter(var==varname, sample=="subsample"))[, 4] %>%
                        as.numeric()),
                    dec=rep(c(1, 1, 2), 2), percentage=rep(c(TRUE, TRUE, FALSE), 2))
      return(tab)
    } else {
      tab <- TexRow(c((descriptive_result %>% 
                         filter(var==varname, sample=="full"))[, 2:4],
                      (descriptive_result %>% 
                         filter(var==varname, sample=="subsample"))[, 2:4]) %>%
                        as.numeric(),
                    dec=rep(c(1, 1, 2), 2), percentage=FALSE)
    }
    return(tab)
  }
  
  tab <- TexRow(c("Sample", "Full", "Subsample"), cspan=c(1, 3, 3)) +
    TexMidrule(list(c(1, 1), c(2, 4), c(5, 7))) +
    TexRow(c("", rep(c("T", "C", "$p(\\Delta)$"), 2))) +
    TexMidrule() +
    TexRow("\\textbf{Children's Characteristics}") +
    TexRow("\\quad \\% Male") / tab_row("sex", proportion=TRUE) +
    TexRow("\\quad \\% Black") / tab_row("black", proportion=TRUE) +
    TexRow("\\quad \\# Siblings") / tab_row("sibling", proportion=FALSE) +
    TexRow("\\quad Gestational Age (Weeks)") / tab_row("gestage", proportion=FALSE) +
    TexRow("") +
    TexRow("\\textbf{Mother's Characteristics}") +
    TexRow("\\quad Mother's IQ") / tab_row("m_iq", proportion=FALSE) +
    TexRow("\\quad Mother's Age") / tab_row("m_age", proportion=FALSE) +
    TexRow("\\quad \\% HS Completed") / tab_row("m_edu_2", proportion=TRUE) +
    TexRow("\\quad \\% College Completed") / tab_row("m_edu_3", proportion=TRUE) +
    TexRow("\\quad \\% Father Figure at Home") / tab_row("mf", proportion=TRUE) +
    TexRow("\\quad \\% Above Poverty") / tab_row("poverty", proportion=TRUE) +
    TexRow("") +
    TexRow("\\textbf{Sample Size}") +
    TexRow("\\quad \\# Observations") / 
    TexRow(c((descriptive_result %>% 
                filter(var=="n", sample=="full"))[, 2:4],
             (descriptive_result %>% 
                filter(var=="n", sample=="subsample"))[, 2:4]) %>%
             as.numeric(),
           dec=0, percentage=FALSE)
  return(tab)
}

tab <- descriptive_stat_balance_tex(descriptive_balance_summary %>% filter(program=="ehs-full"))
TexSave(tab, filename="descriptive_stats_balance_ehs_full", positions=c('l', rep('c', 6)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="descriptive_stats_balance_ehs_full", positions=c('l', rep('c', 6)),
        output_path=output_git, stand_alone=FALSE)

tab <- descriptive_stat_balance_tex(descriptive_balance_summary %>% filter(program=="ehsmixed_center"))
TexSave(tab, filename="descriptive_stats_balance_ehsmixed_center", positions=c('l', rep('c', 6)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="descriptive_stats_balance_ehsmixed_center", positions=c('l', rep('c', 6)),
        output_path=output_git, stand_alone=FALSE)

tab <- descriptive_stat_balance_tex(descriptive_balance_summary %>% filter(program=="ehscenter"))
TexSave(tab, filename="descriptive_stats_balance_ehscenter", positions=c('l', rep('c', 6)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="descriptive_stats_balance_ehscenter", positions=c('l', rep('c', 6)),
        output_path=output_git, stand_alone=FALSE)

tab <- descriptive_stat_balance_tex(descriptive_balance_summary %>% filter(program=="abc"))
TexSave(tab, filename="descriptive_stats_balance_abc", positions=c('l', rep('c', 6)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="descriptive_stats_balance_abc", positions=c('l', rep('c', 6)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
