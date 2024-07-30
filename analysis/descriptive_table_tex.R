start_time <- Sys.time()

covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf")

clean_data <- function(df, subsample=FALSE) {
  df_output <- df %>%
    filter(!is.na(R),
           !is.na(iq),
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

# Table of counts for missing data
count_summary_data <- function(program) {
  count_table <- program %>%
    summarise(n=sum(!is.na(R)),
              n_iq=sum(!is.na(R) &
                         !is.na(iq)),
              n_D=sum(!is.na(R) &
                        !is.na(iq) &
                        !is.na(D)),
              n_alt=sum(!is.na(R) &
                          !is.na(iq) &
                          !is.na(D) &
                          !is.na(alt)),
              n_covariates=sum(!is.na(R) &
                                 !is.na(iq) &  
                                 !is.na(D) & 
                                 !is.na(alt) &
                                 !is.na(m_iq) &
                                 !is.na(black) &
                                 !is.na(sex) &
                                 !is.na(m_age) &
                                 !is.na(sibling) &
                                 !is.na(gestage) &
                                 !is.na(mf) &
                                 m_edu %in% c(1, 2, 3)),
              n_subsample=sum(!is.na(R) &
                                !is.na(iq) & 
                                !is.na(D) & 
                                !is.na(alt) &
                                !is.na(black) &
                                !is.na(m_iq) &
                                !is.na(sex) &
                                !is.na(m_age) &
                                !is.na(sibling) &
                                !is.na(gestage) &
                                !is.na(mf) &
                                black==1 & 
                                m_edu %in% c(1, 2))) %>%
    ungroup()
  
  count_table <- data.frame(value=count_table[1,] %>% as.numeric())
  return(count_table)
}

# Table of descriptive statistics
descriptive_summary_data <- function(program) {
  descriptive_table <- program %>%
    summarise(iq=mean(iq_orig, na.rm=TRUE),
      random=sum(R, na.rm=TRUE)/n(),
      participation=sum(D, na.rm=TRUE)/n(),
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
              n=n()) %>%
    ungroup()
  
  descriptive_table <- data.frame(value=descriptive_table[1,] %>% as.numeric())
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

number_counts <- cbind(data.frame(rowname=c("All",
                                            "Non-Missing Outcome", 
                                            "Non-Missing Participation", 
                                            "Non-Missing Alternate Care", 
                                            "Non-Missing Covariates", 
                                            "Subsample")),
                       count_summary_data(`ehs-full`),
                       count_summary_data(ehsmixed_center),
                       count_summary_data(ehscenter),
                       count_summary_data(abc))

descriptive_summary <- 
  cbind(data.frame(rowname=c("IQ",
                             "\\% Randomized",
                             "\\% Participated",
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
                             "\\# Observations")),
        descriptive_summary_data(clean_data(`ehs-full`)),
        descriptive_summary_data(clean_data(`ehs-full`, subsample=TRUE)),
        descriptive_summary_data(clean_data(ehsmixed_center)),
        descriptive_summary_data(clean_data(ehsmixed_center, subsample=TRUE)),
        descriptive_summary_data(clean_data(ehscenter)),
        descriptive_summary_data(clean_data(ehscenter, subsample=TRUE)),
        descriptive_summary_data(clean_data(abc)),
        descriptive_summary_data(clean_data(abc, subsample=TRUE)))


# Output to LaTeX tables ####
number_counts_tex <- function(counts_result) {
  tab <- TexRow(c("", "EHS", ""), cspan=c(1, 3, 1)) +
    TexMidrule(list(c(2, 4))) +
    TexRow(c("", "Full", "Center $+$ Mixed", "Center Only", "ABC")) +
    TexMidrule() +
    TexRow(counts_result[1, 1]) / TexRow(counts_result[1, 2:5] %>% as.numeric(), dec=0) +
    TexRow(counts_result[2, 1]) / TexRow(counts_result[2, 2:5] %>% as.numeric(), dec=0) +
    TexRow(counts_result[3, 1]) / TexRow(counts_result[3, 2:5] %>% as.numeric(), dec=0) +
    TexRow(counts_result[4, 1]) / TexRow(counts_result[4, 2:5] %>% as.numeric(), dec=0) +
    TexRow(counts_result[5, 1]) / TexRow(counts_result[5, 2:5] %>% as.numeric(), dec=0) +
    TexRow(counts_result[6, 1]) / TexRow(counts_result[6, 2:5] %>% as.numeric(), dec=0)
  return(tab)
}

tab <- number_counts_tex(number_counts)
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

descriptive_stat_tex <- function(descriptive_result) {
  tab <- TexRow(c("", "EHS", ""), 
                cspan=c(1, 6, 2)) +
    TexMidrule(list(c(2, 7), c(8, 9))) +
    TexRow(c("", "Full", "Center $+$ Mixed", "Center Only", "ABC"), 
           cspan=c(1, 2, 2, 2, 2)) +
    TexMidrule(list(c(2, 3), c(4, 5), c(6, 7), c(8, 9))) +
    TexRow(c("", rep(c("Full", "Subsample"), 4))) +
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
    TexRow("") +
    TexRow("\\textbf{Children's Characteristics}") +
    TexRow(paste0("\\quad ", descriptive_result[5, 1])) / 
    TexRow((descriptive_result[5, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[6, 1])) /
    TexRow((descriptive_result[6, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[7, 1])) /
    TexRow((descriptive_result[7, 2:9] %>% as.numeric()), dec=3) +
    TexRow(paste0("\\quad ", descriptive_result[8, 1])) /
    TexRow((descriptive_result[8, 2:9] %>% as.numeric()), dec=1) +
    TexRow("") +
    TexRow("\\textbf{Mother's Characteristics}") +
    TexRow(paste0("\\quad ", descriptive_result[9, 1])) /
    TexRow((descriptive_result[9, 2:9] %>% as.numeric()), dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[10, 1])) /
    TexRow((descriptive_result[10, 2:9] %>% as.numeric()), dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[11, 1])) /
    TexRow((descriptive_result[11, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[12, 1])) /
    TexRow((descriptive_result[12, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow(paste0("\\quad ", descriptive_result[13, 1])) /
    TexRow((descriptive_result[13, 2:9] %>% as.numeric())*100, dec=1) +
    TexRow("") +
    TexRow("\\textbf{Sample Size}") +
    TexRow(paste0("\\quad ", descriptive_result[14, 1])) /
    TexRow((descriptive_result[14, 2:9] %>% as.numeric()), dec=0)
  return(tab)
}

tab <- descriptive_stat_tex(descriptive_summary)
TexSave(tab, filename="descriptive_stats", positions=c('l', rep('c', 8)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="descriptive_stats", positions=c('l', rep('c', 8)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
