# Balance tables for the three EHS program samples (All, Center + Mixed, Center Only)
# (i)  using all randomized observations, and
# (ii) using only observations with non-missing IQ (the respondent sample).
# Replaces the frmttable output from "AttritionEHS AH.do"; formatted to match
# the balance tables produced in descriptive_table_tex.R (e.g., Table A.5).
# Requires preliminary.R to have been sourced (paths and packages).

start_time <- Sys.time()

balance_programs <- c("ehs-full", "ehsmixed_center", "ehscenter")
balance_program_labels <- c("All", "Center $+$ Mixed", "Center Only")

balance_vars <- c("nonmissing_iq", "sex", "black", "sibling", "gestage",
                  "m_iq", "m_age", "m_edu_2", "m_edu_3", "mf", "poverty")

# Load data ####
for (p in balance_programs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=ifelse(!is.na(m_edu), m_edu==2, NA),
                  m_edu_3=ifelse(!is.na(m_edu), m_edu==3, NA)) %>%
           rename(iq=ppvt3y) %>%
           mutate(nonmissing_iq=as.numeric(!is.na(iq))) %>%
           filter(!is.na(R)))
}

# Balance statistics: treatment mean, control mean, p-value of difference ####
balance_summary_data <- function(program, respondents_only=FALSE) {
  if (respondents_only) {
    program <- program %>% filter(nonmissing_iq==1)
  }
  
  balance_table <- data.frame()
  for (var in balance_vars) {
    treat <- program %>% filter(R==1) %>% pull(all_of(var))
    control <- program %>% filter(R==0) %>% pull(all_of(var))
    treat <- treat[!is.na(treat)]
    control <- control[!is.na(control)]
    if (sd(treat)==0 | sd(control)==0) {
      diff_p <- 1
    } else {
      diff_p <- t.test(treat, control)$p.value
    }
    balance_table <- rbind(balance_table,
                           data.frame(var=var,
                                      value_treatment=mean(treat),
                                      value_control=mean(control),
                                      p_value=diff_p))
  }
  
  balance_table <- rbind(balance_table,
                         data.frame(var="n",
                                    value_treatment=sum(program$R==1),
                                    value_control=sum(program$R==0),
                                    p_value=NA))
  return(balance_table)
}

balance_three_programs_all <- data.frame()
balance_three_programs <- data.frame()
for (p in balance_programs) {
  balance_three_programs_all <-
    rbind(balance_three_programs_all,
          balance_summary_data(get(p)) %>% mutate(program=p))
  balance_three_programs <-
    rbind(balance_three_programs,
          balance_summary_data(get(p), respondents_only=TRUE) %>% mutate(program=p))
}

# Output to LaTeX tables ####
balance_three_programs_tex <- function(balance_result, nonmissing_row=FALSE) {
  tab_row <- function(varname, proportion=FALSE) {
    values <- c()
    for (p in balance_programs) {
      row <- balance_result %>% filter(var==varname, program==p)
      values <- c(values,
                  row$value_treatment*ifelse(proportion, 100, 1),
                  row$value_control*ifelse(proportion, 100, 1),
                  row$p_value)
    }
    tab <- TexRow(values,
                  dec=rep(c(1, 1, 2), 3),
                  percentage=rep(c(proportion, proportion, FALSE), 3))
    return(tab)
  }
  
  tab <- TexRow(c("Program", balance_program_labels), cspan=c(1, 3, 3, 3)) +
    TexMidrule(list(c(1, 1), c(2, 4), c(5, 7), c(8, 10))) +
    TexRow(c("", rep(c("T", "C", "$p(\\Delta)$"), 3))) +
    TexMidrule()
  
  if (nonmissing_row) {
    tab <- tab +
      TexRow("\\textbf{Outcome}") +
      TexRow("\\quad \\% Non-Missing IQ") / tab_row("nonmissing_iq", proportion=TRUE) +
      TexRow("")
  }
  
  tab <- tab +
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
    TexRow(unlist(lapply(balance_programs, function(p) {
      row <- balance_result %>% filter(var=="n", program==p)
      c(row$value_treatment, row$value_control, NA)
    })),
    dec=0, percentage=FALSE)
  return(tab)
}

tab <- balance_three_programs_tex(balance_three_programs_all, nonmissing_row=TRUE)
TexSave(tab, filename="balance_three_programs_all", positions=c('l', rep('c', 9)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="balance_three_programs_all", positions=c('l', rep('c', 9)),
        output_path=output_git, stand_alone=FALSE)

tab <- balance_three_programs_tex(balance_three_programs, nonmissing_row=FALSE)
TexSave(tab, filename="balance_three_programs", positions=c('l', rep('c', 9)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="balance_three_programs", positions=c('l', rep('c', 9)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
