start_time <- Sys.time()

covariates_all <- c("m_iq", "black", "sex",
                    "m_age", "m_edu_2", "m_edu_3",
                    "sibling", "gestage", "mf")

# Table of counts for missing data
clean_data <- function(p, p_name) {
  count_table <- p %>%
    summarise(n=n(),
              n_iq=sum(!is.na(iq)),
              n_D=sum(!is.na(iq) &
                        !is.na(D)),
              n_alt=sum(!is.na(iq) &
                          !is.na(D) &
                          !is.na(alt)),
              n_covariates=sum(!is.na(iq) &  
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
              n_subsample=sum(!is.na(iq) & 
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


# Execute! ####
# Load data
programs_ehs <- c("ehs-full", "ehsmixed_center", "ehscenter")
programs <- c(programs_ehs, "abc")

for (p in programs_ehs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
                  m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA)) %>%
           rename(iq=ppvt3y))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(D=D_12,
         alt=P_12,
         m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
         m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA),
         caregiver_home=1) %>%
  rename(iq=sb3y)

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
                       clean_data(`ehs-full`, "EHS - Full"),
                       clean_data(ehsmixed_center, "EHS - Center + Mixed"),
                       clean_data(ehscenter, "EHS - Center Only"),
                       clean_data(abc, "ABC"))


# Output to LaTeX tables ####
number_counts_tex <- function(counts_result) {
  tab <- TexRow(c("", "EHS", ""), cspan=c(1, 3, 1)) +
    TexMidrule(list(c(2, 4))) +
    TexRow(c("", "Full", "Center $+$ Mixed", "Center Only", "ABC")) +
    TexMidrule() +
    TexRow(number_counts[1, 1]) / TexRow(number_counts[1, 2:5] %>% as.numeric(), dec=0) +
    TexRow(number_counts[2, 1]) / TexRow(number_counts[2, 2:5] %>% as.numeric(), dec=0) +
    TexRow(number_counts[3, 1]) / TexRow(number_counts[3, 2:5] %>% as.numeric(), dec=0) +
    TexRow(number_counts[4, 1]) / TexRow(number_counts[4, 2:5] %>% as.numeric(), dec=0) +
    TexRow(number_counts[5, 1]) / TexRow(number_counts[5, 2:5] %>% as.numeric(), dec=0) +
    TexRow(number_counts[6, 1]) / TexRow(number_counts[6, 2:5] %>% as.numeric(), dec=0)
  return(tab)
}

tab <- number_counts_tex(number_counts)
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="number_counts", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)


end_time <- Sys.time()
end_time-start_time
